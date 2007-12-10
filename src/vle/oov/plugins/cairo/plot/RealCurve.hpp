/** 
 * @file RealCurve.hpp
 * @brief 
 * @author The vle Development Team
 * @date ven, 27 jan 2006 16:10:20 +0100
 */

/*
 * Copyright (C) 2006-2007 - The vle Development Team
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License
 * as published by the Free Software Foundation; either version 2
 * of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
 */

#ifndef VLE_OOV_PLUGINS_CAIRO_PLOT_REALCURVE_HPP
#define VLE_OOV_PLUGINS_CAIRO_PLOT_REALCURVE_HPP

#include <vle/oov/plugins/cairo/plot/Parameter.hpp>
#include <vle/oov/plugins/cairo/plot/Curve.hpp>
#include <vector>
#include <cairomm/cairomm.h>

namespace vle { namespace oov { namespace plugin {

class RealCurve: public Curve
{
private :
    std::vector < std::pair < double, double > > m_valueList;
    std::string const m_type;
    
public :
    RealCurve(const std::string & name,
	      unsigned int r,
	      unsigned int g,
	      unsigned int b) : Curve(name, r, g, b) 
	{ }
    
    virtual ~RealCurve() { }
    
    void add(double date, double value);
    
    void draw(Cairo::RefPtr < Cairo::Context > ctx, Parameter & m_parameter);
    
    double get_last_value() const;
    
    bool is_double() { return true; }
    
    const int get_size() { return m_valueList.size(); }
    
    const void get_min_max_value(int number_value, double & min, double &
				 max, Parameter & m_parameter);
    
    const double get_min_value(int number_value, Parameter & m_parameter);
    
    const double get_max_value(int number_value, Parameter & m_parameter);
    
    const int get_number_value();
    
    const double get_date(int index);
    
    const double get_value(int index);
    
    const void get_min_max_value_prec_index(int indice, int number_value,
					    double & min, double & max);
    
    const double get_min_value_prec_index(int indice, int number_value);
    
    const double get_max_value_prec_index(int indice, int number_value);
    
};
	    
}}} // namespace vle oov plugin

#endif