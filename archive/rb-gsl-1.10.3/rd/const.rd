=begin
= Physical Constants

The GSL physical constants are defined as Ruby constants under the
modules 
  * (({GSL::CONST::MKSA})) (MKSA unit)
  * (({GSL::CONST:CGSM}))  (CGSM unit)
  * (({GSL::CONST:NUM}))   (Dimension-less constants)
For example, the GSL C constant 
(({GSL_CONST_MKSA_SPEED_OF_LIGHT})) is represented by a Ruby constant,
      GSL_CONST_MKSA_SPEED_OF_LIGHT  ---> GSL::CONST::MKSA::SPEED_OF_LIGHT

The following lists a part of the constants. Most of the constants are
defined both in the modules (({GSL::CONST::MKSA})) and (({GSL::CONST::CGSM})).
See also the ((<GSL reference|URL:http://www.gnu.org/software/gsl/manual/gsl-ref_37.html#SEC479>))

Contents:
(1) ((<Fundamental Constants|URL:const.html#1>))
(2) ((<Astronomy and Astrophysics|URL:const.html#2>))
(3) ((<Atomic and Nuclear Physics|URL:const.html#3>))
(4) ((<Measurement of Time|URL:const.html#4>))
(5) ((<Imperial Units|URL:const.html#5>))
(6) ((<Nautical Units|URL:const.html#6>))
(7) ((<Printers Units|URL:const.html#7>))
(8) ((<Volume|URL:const.html#8>))
(9) ((<Mass and Weight|URL:const.html#9>))
(10) ((<Thermal Energy and Power|URL:const.html#10>))
(11) ((<Pressure|URL:const.html#11>))
(12) ((<Viscosity|URL:const.html#12>))
(13) ((<Light and Illumination|URL:const.html#13>))
(14) ((<Radioactivity|URL:const.html#14>))
(15) ((<Force and Energy|URL:const.html#15>))
(16) ((<Prefixes|URL:const.html#16>))
(17) ((<Examples|URL:const.html#17>))

== Fundamental Constants
--- GSL::CONST::MKSA::SPEED_OF_LIGHT
    The speed of light in vacuum, c.
--- GSL::CONST::MKSA::VACUUM_PERMEABILITY 
    The permeability of free space, \mu (not defined in GSL::CONST::CGSM).
--- GSL::CONST::MKSA::VACUUM_PERMITTIVITY
    The permittivity of free space, \epsilon_0 (not defined in GSL::CONST::CGSM).
--- GSL::CONST::MKSA::PLANCKS_CONSTANT_H
    Planck's constant, ((|h|)).
--- GSL::CONST::MKSA::PLANCKS_CONSTANT_HBAR
    Planck's constant divided by 2\pi, \hbar.
--- GSL::CONST::NUM::AVOGADRO
    Avogadro's number
--- GSL::CONST::MKSA::FARADAY
    The molar charge of 1 Faraday.
--- GSL::CONST::MKSA::BOLTZMANN
    The Boltzmann constant, k.
--- GSL::CONST::MKSA::STEFAN_BOLTZMANN_CONSTANT
    The Stefan-Boltzmann constant, \sigma.
--- GSL::CONST::MKSA::MOLAR_GAS
    The molar gas constant, R_0.
--- GSL::CONST::MKSA::STANDARD_GAS_VOLUME
    The standard gas volume, V_0.
--- GSL::CONST::MKSA::GAUSS
    The magnetic field of 1 Gauss.
#--- GSL::CONST::MKSA::MICRON
#    The length of 1 micron.
#--- GSL::CONST::MKSA::HECTARE
#    The area of 1 hectare.
#--- GSL::CONST::MKSA::MILES_PER_HOUR
#    The speed of 1 mile per hour.
#--- GSL::CONST::MKSA::KILOMETERS_PER_HOUR
#    The speed of 1 kilometer per hour.

== Astronomy and Astrophysics
--- GSL::CONST::MKSA::ASTRONOMICAL_UNIT
    The length of 1 astronomical unit (mean earth-sun distance), AU.
--- GSL::CONST::MKSA::GRAVITATIONAL_CONSTANT
    The gravitational constant, G.
--- GSL::CONST::MKSA::LIGHT_YEAR
    The distance of 1 light-year, ly.
--- GSL::CONST::MKSA::PARSEC
    The distance of 1 parsec, pc.
--- GSL::CONST::MKSA::GRAV_ACCEL
    The standard gravitational acceleration on Earth, g.
--- GSL::CONST::MKSA::SOLAR_MASS
    The mass of the Sun.

== Atomic and Nuclear Physics
--- GSL::CONST::MKSA::ELECTRON_CHARGE
    The charge of the electron, e.
--- GSL::CONST::CGSM::ELECTRON_CHARGE_ESU
    The charge of the electron, e, in esu unit (not defined in GSL::CONST::MKSA).
--- GSL::CONST::MKSA::ELECTRON_VOLT
    The energy of 1 electron volt, eV.
--- GSL::CONST::MKSA::UNIFIED_ATOMIC_MASS
    The unified atomic mass, amu.
--- GSL::CONST::MKSA::MASS_ELECTRON
    The mass of the electron, m_e.
--- GSL::CONST::MKSA::MASS_MUON
    The mass of the muon, m_\mu.
--- GSL::CONST::MKSA::MASS_PROTON
    The mass of the proton, m_p.
--- GSL::CONST::MKSA::MASS_NEUTRON
    The mass of the proton, m_n.
--- GSL::CONST::NUM::FINE_STRUCTURE
    The electromagnetic fine structure constant alpha.
--- GSL::CONST::MKSA::RYDBERG
    The Rydberg constant, Ry, in units of energy. This is related to the Rydberg inverse wavelength R by Ry = h c R.
--- GSL::CONST::MKSA::THOMSON_CROSS_SECTION
    The Thomson cross section of photon scattering by electrons.
--- GSL::CONST::MKSA::BOHR_RADIUS
    The Bohr radius, a_0.
--- GSL::CONST::MKSA::ANGSTROM
    The length of 1 angstrom.
--- GSL::CONST::MKSA::BARN
    The area of 1 barn.
--- GSL::CONST::MKSA::BOHR_MAGNETON
    The Bohr Magneton, mu_B.
--- GSL::CONST::MKSA::NUCLEAR_MAGNETON
    The Nuclear Magneton, mu_N.
--- GSL::CONST::MKSA::ELECTRON_MAGNETIC_MOMENT
    The absolute value of the magnetic moment of the electron, mu_e. The physical magnetic moment of the electron is negative.
--- GSL::CONST::MKSA::PROTON_MAGNETIC_MOMENT
    The magnetic moment of the proton, mu_p.

== Measurement of Time
--- GSL::CONST::MKSA::MINUTE
    The number of seconds in 1 minute.
--- GSL::CONST::MKSA::HOUR
    The number of seconds in 1 hour.
--- GSL::CONST::MKSA::DAY
    The number of seconds in 1 day.
--- GSL::CONST::MKSA::WEEK
    The number of seconds in 1 week.

== Imperial Units
--- GSL::CONST::MKSA::INCH
    The length of 1 inch.
--- GSL::CONST::MKSA::FOOT
    The length of 1 foot.
--- GSL::CONST::MKSA::YARD
    The length of 1 yard.
--- GSL::CONST::MKSA::MILE
    The length of 1 mile.
--- GSL::CONST::MKSA::MIL
    The length of 1 mil (1/1000th of an inch).

== Nautical Units
--- GSL::CONST::MKSA::NAUTICAL_MILE
    The length of 1 nautical mile.
--- GSL::CONST::MKSA::FATHOM
    The length of 1 fathom.
--- GSL::CONST::MKSA::KNOT
    The speed of 1 knot.

== Printers Units
--- GSL::CONST::MKSA::POINT
    The length of 1 printer's point (1/72 inch).
--- GSL::CONST::MKSA::TEXPOINT
    The length of 1 TeX point (1/72.27 inch).

== Volume
--- GSL::CONST::MKSA::ACRE
    The area of 1 acre.
--- GSL::CONST::MKSA::LITER
    The volume of 1 liter.
--- GSL::CONST::MKSA::US_GALLON
    The volume of 1 US gallon.
--- GSL::CONST::MKSA::CANADIAN_GALLON
    The volume of 1 Canadian gallon.
--- GSL::CONST::MKSA::UK_GALLON
    The volume of 1 UK gallon.
--- GSL::CONST::MKSA::QUART
    The volume of 1 quart.
--- GSL::CONST::MKSA::PINT
    The volume of 1 pint.

== Mass and Weight
--- GSL::CONST::MKSA::POUND_MASS
    The mass of 1 pound.
--- GSL::CONST::MKSA::OUNCE_MASS
    The mass of 1 ounce.
--- GSL::CONST::MKSA::TON
    The mass of 1 ton.
--- GSL::CONST::MKSA::METRIC_TON
    The mass of 1 metric ton (1000 kg).
--- GSL::CONST::MKSA::UK_TON
    The mass of 1 UK ton.
--- GSL::CONST::MKSA::TROY_OUNCE
    The mass of 1 troy ounce.
--- GSL::CONST::MKSA::CARAT
    The mass of 1 carat.
--- GSL::CONST::MKSA::GRAM_FORCE
    The force of 1 gram weight.
--- GSL::CONST::MKSA::POUND_FORCE
    The force of 1 pound weight.
--- GSL::CONST::MKSA::KILOPOUND_FORCE
    The force of 1 kilopound weight.
--- GSL::CONST::MKSA::POUNDAL
    The force of 1 poundal.

== Thermal Energy and Power
--- GSL::CONST::MKSA::CALORIE
    The energy of 1 calorie.
--- GSL::CONST::MKSA::BTU
    The energy of 1 British Thermal Unit, btu.
--- GSL::CONST::MKSA::THERM
    The energy of 1 Therm.
--- GSL::CONST::MKSA::HORSEPOWER
    The power of 1 horsepower.

== Pressure
--- GSL::CONST::MKSA::BAR
    The pressure of 1 bar.
--- GSL::CONST::MKSA::STD_ATMOSPHERE
    The pressure of 1 standard atmosphere.
--- GSL::CONST::MKSA::TORR
    The pressure of 1 torr.
--- GSL::CONST::MKSA::METER_OF_MERCURY
    The pressure of 1 meter of mercury.
--- GSL::CONST::MKSA::INCH_OF_MERCURY
    The pressure of 1 inch of mercury.
--- GSL::CONST::MKSA::INCH_OF_WATER
    The pressure of 1 inch of water.
--- GSL::CONST::MKSA::PSI
    The pressure of 1 pound per square inch.

== Viscosity
--- GSL::CONST::MKSA::POISE
    The dynamic viscosity of 1 poise.
--- GSL::CONST::MKSA::STOKES
    The kinematic viscosity of 1 stokes.

== Light and Illumination
--- GSL::CONST::MKSA::STILB
    The luminance of 1 stilb.
--- GSL::CONST::MKSA::LUMEN
    The luminous flux of 1 lumen.
--- GSL::CONST::MKSA::LUX
    The illuminance of 1 lux.
--- GSL::CONST::MKSA::PHOT
    The illuminance of 1 phot.
--- GSL::CONST::MKSA::FOOTCANDLE
    The illuminance of 1 footcandle.
--- GSL::CONST::MKSA::LAMBERT
    The luminance of 1 lambert.
--- GSL::CONST::MKSA::FOOTLAMBERT
    The luminance of 1 footlambert.

== Radioactivity
--- GSL::CONST::MKSA::CURIE
    The activity of 1 curie.
--- GSL::CONST::MKSA::ROENTGEN
    The exposure of 1 roentgen.
--- GSL::CONST::MKSA::RAD
    The absorbed dose of 1 rad.

== Force and Energy
--- GSL::CONST::MKSA::NEWTON
    The SI unit of force, 1 Newton.
--- GSL::CONST::MKSA::DYNE
    he force of 1 Dyne = 10^-5 Newton.
--- GSL::CONST::MKSA::JOULE
    The SI unit of energy, 1 Joule.
--- GSL::CONST::MKSA::ERG
    The energy 1 erg = 10^-7 Joule.

== Prefixes
--- GSL::CONST::NUM::YOTTA
    10^24
--- GSL::CONST::NUM::ZETTA
    10^21
--- GSL::CONST::NUM::EXA
    10^18
--- GSL::CONST::NUM::PETA
    10^15
--- GSL::CONST::NUM::TERA
    10^12
--- GSL::CONST::NUM::GIGA
    10^9
--- GSL::CONST::NUM::MEGA
    10^6
--- GSL::CONST::NUM::KILO
    10^3
--- GSL::CONST::NUM::MILLI
    10^-3
--- GSL::CONST::NUM::MICRO
    10^-6
--- GSL::CONST::NUM::NANO
    10^-9
--- GSL::CONST::NUM::PICO
    10^-12
--- GSL::CONST::NUM::FEMTO
    10^-15
--- GSL::CONST::NUM::ATTO
    10^-18
--- GSL::CONST::NUM::ZEPTO
    10^-21
--- GSL::CONST::NUM::YOCTO
    10^-24

== Example
The following program demonstrates the use of the physical constants in a 
calculation. In this case, the goal is to calculate the range of light-travel 
times from Earth to Mars.

     require("gsl")
     include GSL::CONST::MKSA

     puts("In MKSA unit")

     c  = SPEED_OF_LIGHT;
     au = ASTRONOMICAL_UNIT;
     minutes = MINUTE;

     # distance stored in meters 
     r_earth = 1.00 * au;  
     r_mars  = 1.52 * au;

     t_min = (r_mars - r_earth) / c;
     t_max = (r_mars + r_earth) / c;

     printf("light travel time from Earth to Mars:\n");
     printf("c = %e [m/s]\n", c)
     printf("AU = %e [m]\n", au)
     printf("minutes = %e [s]\n", minutes)
     printf("minimum = %.1f minutes\n", t_min / minutes);
     printf("maximum = %.1f minutes\n\n", t_max / minutes);

((<prev|URL:bspline.html>))
((<next|URL:graph.html>))

((<Reference index|URL:ref.html>))
((<top|URL:index.html>))

=end
