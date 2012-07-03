/*
 * @file vle/utils/RemoteManager.cpp
 *
 * This file is part of VLE, a framework for multi-modeling, simulation
 * and analysis of complex dynamical systems
 * http://www.vle-project.org
 *
 * Copyright (c) 2003-2007 Gauthier Quesnel <quesnel@users.sourceforge.net>
 * Copyright (c) 2003-2010 ULCO http://www.univ-littoral.fr
 * Copyright (c) 2007-2010 INRA http://www.inra.fr
 *
 * See the AUTHORS or Authors.txt file for copyright owners and contributors
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */


#include <vle/utils/RemoteManager.hpp>
#include <vle/utils/Algo.hpp>
#include <vle/utils/DownloadManager.hpp>
#include <vle/utils/Exception.hpp>
#include <vle/utils/Path.hpp>
#include <vle/utils/Package.hpp>
#include <vle/utils/Preferences.hpp>
#include <vle/utils/Trace.hpp>
#include <vle/utils/details/Package.hpp>
#include <vle/utils/details/PackageParser.hpp>
#include <vle/version.hpp>
#include <boost/filesystem.hpp>
#include <boost/algorithm/string/predicate.hpp>
#include <boost/algorithm/string/join.hpp>
#include <boost/algorithm/string/split.hpp>
#include <boost/algorithm/string/trim.hpp>
#include <boost/lexical_cast.hpp>
#include <boost/cast.hpp>
#include <boost/filesystem.hpp>
#include <boost/thread/thread.hpp>
#include <boost/unordered_map.hpp>
#include <boost/regex.hpp>
#include <fstream>
#include <ostream>
#include <string>

#define PACKAGESID_VECTOR_RESERVED_SIZE 100u

namespace vle { namespace utils {

namespace fs = boost::filesystem;

static std::string buildLocalPackageFilename()
{
    return utils::Path::path().getHomeFile("packages.local");
}

static std::string buildRemotePackageFilename()
{
    return utils::Path::path().getHomeFile("packages.remote");
}

static void BuildLocalPackage(PackagesIdSet *pkgs)
{
    fs::path pkgsdir(utils::Path::path().getPackageDir());

    if (fs::exists(pkgsdir) and fs::is_directory(pkgsdir)) {
        for (fs::directory_iterator it(pkgsdir), end; it != end; ++it) {
            if (fs::is_directory(it->status())) {
                fs::path descfile = *it;
                descfile /= "Description.txt";

                if (fs::exists(descfile)) {
                    PackageId p;
                    if (LoadPackage(descfile.filename().string(),
                                    std::string(), &p)) {
                        pkgs->insert(p);
                    }
                }
            }
        }
    }
}

class RemoteManager::Pimpl
{
public:
    Pimpl()
        : mStream(0), mIsStarted(false), mIsFinish(false), mStop(false),
          mHasError(false)
    {
        mPackages.reserve(PACKAGESID_VECTOR_RESERVED_SIZE);

        if (!LoadPackages(buildLocalPackageFilename(), std::string(), &local)) {
            BuildLocalPackage(&local);
        }

        LoadPackages(buildRemotePackageFilename(), "distant", &remote);
    }

    Pimpl(std::istream& in)
        : mStream(0), mIsStarted(false), mIsFinish(false), mStop(false),
          mHasError(false)
    {
        mPackages.reserve(PACKAGESID_VECTOR_RESERVED_SIZE);

        LoadPackages(in, std::string(), &local);
    }

    ~Pimpl()
    {
        join();
    }

    void start(RemoteManagerActions action, const std::string& arg,
               std::ostream* out)
    {
        if (not mIsStarted) {
            mIsStarted = true;
            mIsFinish = false;
            mStop = false;
            mHasError = false;
            mArgs = arg;
            mStream = out;
            mPackages.clear();

            switch (action) {
            case REMOTE_MANAGER_UPDATE:
                mThread = boost::thread(
                    &RemoteManager::Pimpl::actionUpdate, this);
                break;
            case REMOTE_MANAGER_SOURCE:
                mThread = boost::thread(
                    &RemoteManager::Pimpl::actionSource, this);
                break;
            case REMOTE_MANAGER_INSTALL:
                mThread = boost::thread(
                    &RemoteManager::Pimpl::actionInstall, this);
                break;
            case REMOTE_MANAGER_SEARCH:
                mThread = boost::thread(
                    &RemoteManager::Pimpl::actionSearch, this);
                break;
            case REMOTE_MANAGER_SHOW:
                mThread = boost::thread(
                    &RemoteManager::Pimpl::actionShow, this);
                break;
            default:
                break;
            }
        }
    }

    void join()
    {
        if (mIsStarted) {
            if (not mIsFinish) {
                mThread.join();
            }
        }
    }

    void stop()
    {
        if (mIsStarted and not mIsFinish) {
            mStop = true;
        }
    }

    /**
     * Send the parameter of the template function \c t to
     *
     * @param t
     */
    template < typename T > void out(const T& t)
    {
        if (mStream) {
            *mStream << t;
        }
    }

    /**
     * A functor to check if a @c Packages::value_type corresponds to the
     * regular expression provided in constructor.
     */
    struct NotHaveExpression
        : std::unary_function < PackageId, bool >
    {
        const boost::regex& expression;

        NotHaveExpression(const boost::regex& expression)
            : expression(expression)
        {
        }

        bool operator()(const PackageId& pkg) const
        {
            boost::match_results < std::string::const_iterator > what;

            if (boost::regex_match(pkg.name,
                                   what,
                                   expression,
                                   boost::match_default |
                                   boost::match_partial)) {
                return false;
            }

            if (boost::regex_match(pkg.description,
                                   what,
                                   expression,
                                   boost::match_default |
                                   boost::match_partial)) {
                return false;
            }

            return true;
        }
    };

    void read(const std::string& filename)
    {
        PackagesIdSet tmpremote;

        if (not LoadPackages(filename, "distant", &tmpremote)) {
            TraceAlways(fmt(_("Failed to open package file `%1%'")) % filename);
        }
    }

    void save() const throw()
    {
        try {
            {
                std::ofstream file(buildLocalPackageFilename().c_str());
                file.exceptions(std::ios_base::eofbit |
                                std::ios_base::failbit |
                                std::ios_base::badbit);

                file << local << std::endl;
            }

            {
                std::ofstream file(buildRemotePackageFilename().c_str());
                file.exceptions(std::ios_base::eofbit |
                                std::ios_base::failbit |
                                std::ios_base::badbit);

                file << remote << std::endl;
            }
        } catch (const std::exception& e) {
            TraceAlways(fmt(_("Failed to write package file `%1%' or `%2%'")) %
                        buildLocalPackageFilename() %
                        buildRemotePackageFilename());
        }
    }

    //
    // threaded slot
    //

    struct Download
        : public std::unary_function < std::string, void >
    {
        PackagesIdSet* pkgs;

        Download(PackagesIdSet* pkgs)
        : pkgs(pkgs)
        {
            assert(pkgs);
        }

        void operator()(const std::string& url) const
        {
            DownloadManager dl;

            std::string pkgurl(url);
            pkgurl += "/packages";

            dl.start(pkgurl);
            dl.join();

            if (not dl.hasError()) {
                LoadPackages(dl.filename(), url, pkgs);
            }
        }
    };

    void actionUpdate() throw()
    {
        std::vector < std::string > urls;

        try {
            utils::Preferences prefs;
            std::string tmp;
            prefs.get("vle.remote.url", &tmp);

            boost::algorithm::split(urls, tmp,
                                    boost::algorithm::is_any_of(","),
                                    boost::algorithm::token_compress_on);
        } catch(const std::exception& /*e*/) {
            TraceAlways(_("Failed to read preferences file"));
        }

        PackagesIdSet updated;
        std::for_each(urls.begin(), urls.end(),
                      Download(&updated));

        if (not updated.empty()) {
            std::set_intersection(local.begin(),
                                  local.end(),
                                  updated.begin(),
                                  updated.end(),
                                  std::back_inserter(mPackages),
                                  PackageIdUpdate());
        }

        mStream = 0;
        mIsFinish = true;
        mIsStarted = false;
        mStop = false;
        mHasError = false;
    }

    void actionInstall() throw()
    {
        // const_iterator it = mPackages.find(mArgs);

        // if (it != mPackages.end()) {
        //     std::string url = it->second.getBinaryPackageUrl();

        //     DownloadManager dl;

        //     out(fmt(_("Download binary package `%1%' at %2%")) % mArgs % url);
        //     dl.start(url);
        //     dl.join();

        //     if (not dl.hasError()) {
        //         out(_("install"));
        //         std::string filename = dl.filename();
        //         std::string zipfilename = dl.filename();
        //         zipfilename += ".zip";

        //         boost::filesystem::rename(filename, zipfilename);

        //         utils::Package::package().unzip(mArgs, zipfilename);
        //         utils::Package::package().wait(*mStream, *mStream);
        //         out(_(": ok\n"));
        //     } else {
        //         out(_(": failed\n"));
        //     }
        // } else {
        //     out(fmt(_("Unknown package `%1%'")) % mArgs);
        // }

        // mStream = 0;
        // mIsFinish = true;
        // mIsStarted = false;
        // mStop = false;
        // mHasError = false;
    }

    void actionSource() throw()
    {
        // const_iterator it = mPackages.find(mArgs);

        // if (it != mPackages.end()) {
        //     std::string url = it->second.getSourcePackageUrl();

        //     DownloadManager dl;

        //     out(fmt(_("Download source package `%1%' at %2%")) % mArgs % url);
        //     dl.start(url);
        //     dl.join();

        //     if (not dl.hasError()) {
        //         out(_("install"));
        //         std::string filename = dl.filename();
        //         std::string zipfilename = dl.filename();
        //         zipfilename += ".zip";

        //         boost::filesystem::rename(filename, zipfilename);

        //         utils::Package::package().unzip(mArgs, zipfilename);
        //         utils::Package::package().wait(*mStream, *mStream);
        //         out(_(": ok\n"));
        //     } else {
        //         out(_(": failed\n"));
        //     }
        // } else {
        //     out(fmt(_("Unknown package `%1%'")) % mArgs);
        // }

        // mStream = 0;
        // mIsFinish = true;
        // mIsStarted = false;
        // mStop = false;
        // mHasError = false;
    }

    void actionSearch() throw()
    {
        boost::regex expression(mArgs, boost::regex::grep);

        std::remove_copy_if(local.begin(),
                            local.end(),
                            std::back_inserter(mPackages),
                            NotHaveExpression(expression));

        std::remove_copy_if(remote.begin(),
                            remote.end(),
                            std::back_inserter(mPackages),
                            NotHaveExpression(expression));

        mStream = 0;
        mIsFinish = true;
        mIsStarted = false;
        mStop = false;
        mHasError = false;
    }

    void actionShow() throw()
    {
        std::vector < std::string > args;

        boost::algorithm::split(args, mArgs,
                                boost::algorithm::is_any_of(" "),
                                boost::algorithm::token_compress_on);

        std::vector < std::string >::iterator it, end;

        for (it = args.begin(), end = args.end(); it != end; ++it) {
            PackageId tmp;

            tmp.name = *it;

            std::pair < PackagesIdSet::iterator,
                PackagesIdSet::iterator > found;

            found = local.equal_range(tmp);

            std::copy(found.first,
                      found.second,
                      std::back_inserter(mPackages));

            found = remote.equal_range(tmp);

            std::copy(found.first,
                      found.second,
                      std::back_inserter(mPackages));
        }

        mStream = 0;
        mIsFinish = true;
        mIsStarted = false;
        mStop = false;
        mHasError = false;
    }

    PackagesIdSet local;
    PackagesIdSet remote;
    Packages mPackages;
    boost::mutex mMutex;
    boost::thread mThread;
    std::string mArgs;
    std::ostream* mStream;
    bool mIsStarted;
    bool mIsFinish;
    bool mStop;
    bool mHasError;
};

RemoteManager::RemoteManager()
    : mPimpl(new RemoteManager::Pimpl())
{
}

RemoteManager::RemoteManager(std::istream& in)
    : mPimpl(new RemoteManager::Pimpl(in))
{
}

RemoteManager::~RemoteManager()
{
    delete mPimpl;
}

void RemoteManager::start(RemoteManagerActions action,
                          const std::string& arg,
                          std::ostream* os)
{
    mPimpl->start(action, arg, os);
}

void RemoteManager::join()
{
    mPimpl->join();
}

void RemoteManager::stop()
{
    mPimpl->stop();
}

void RemoteManager::getResult(Packages *out)
{
    if (out) {
        out->clear();
        out->reserve(mPimpl->mPackages.size());

        std::copy(mPimpl->mPackages.begin(),
                  mPimpl->mPackages.end(),
                  std::back_inserter(*out));
    }
}

}} // namespace vle utils
