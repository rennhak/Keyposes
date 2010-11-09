#ifndef GEOMETRY_H
#define GEOMETRY_H

#include <math.h>

const double pi = 3.14159;

bool TwoCirclesOverlapped(double x1, double y1, double r1,
                          double x2, double y2, double r2);

bool TwoCirclesEnclosed(double x1, double y1, double r1,
                        double x2, double y2, double r2);


bool TwoCirclesIntersectionPoints(double x1, double y1, double r1,
                                  double x2, double y2, double r2,
                                  double &p3X, double &p3Y,
                                  double &p4X, double &p4Y);

double TwoCirclesIntersectionArea(double x1, double y1, double r1,
                                  double x2, double y2, double r2);

double CircleArea(double radius);
                                  


#endif