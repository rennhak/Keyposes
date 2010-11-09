#include "geometry.h"


//----------------------------- TwoCirclesOverlapped ---------------------
//
//  Returns true if the two circles overlap
//------------------------------------------------------------------------
bool TwoCirclesOverlapped(double x1, double y1, double r1,
                          double x2, double y2, double r2)
{
  double DistBetweenCenters = sqrt( (x1-x2) * (x1-x2) +
                                    (y1-y2) * (y1-y2));

  if ((DistBetweenCenters < (r1+r2)) || (DistBetweenCenters < fabs(r1-r2)))
  {
    return true;
  }

  return false;
}

//--------------------------- TwoCirclesEnclosed ---------------------------
//
//  returns true if one circle encloses the other
//-------------------------------------------------------------------------
bool TwoCirclesEnclosed(double x1, double y1, double r1,
                        double x2, double y2, double r2)
{
  double DistBetweenCenters = sqrt( (x1-x2) * (x1-x2) +
                                    (y1-y2) * (y1-y2));

  if (DistBetweenCenters < fabs(r1-r2))
  {
    return true;
  }

  return false;
}

//------------------------ TwoCirclesIntersectionPoints ------------------
//
//  Given two circles this function calculates the intersection points
//  of any overlap.
//
//  returns false if no overlap found
//
// see http://astronomy.swin.edu.au/~pbourke/geometry/2circle/
//------------------------------------------------------------------------ 
bool TwoCirclesIntersectionPoints(double x1, double y1, double r1,
                                  double x2, double y2, double r2,
                                  double &p3X, double &p3Y,
                                  double &p4X, double &p4Y)
{
  //first check to see if they overlap
  if (!TwoCirclesOverlapped(x1,y1,r1,x2,y2,r2))
  {
    return false;
  }

  //calculate the distance between the circle centers
  double d = sqrt( (x1-x2) * (x1-x2) + (y1-y2) * (y1-y2));
  
  //Now calculate the distance from the center of each circle to the center
  //of the line which connects the intersection points.
  double a = (r1 - r2 + (d * d)) / (2 * d);
  double b = (r2 - r1 + (d * d)) / (2 * d);
  

  //MAYBE A TEST FOR EXACT OVERLAP? 

  //calculate the point P2 which is the center of the line which 
  //connects the intersection points
  double p2X, p2Y;

  p2X = x1 + a * (x2 - x1) / d;
  p2Y = y1 + a * (y2 - y1) / d;

  //calculate first point
  double h1 = sqrt((r1 * r1) - (a * a));

  p3X = p2X - h1 * (y2 - y1) / d;
  p3Y = p2Y + h1 * (x2 - x1) / d;


  //calculate second point
  double h2 = sqrt((r2 * r2) - (a * a));

  p4X = p2X + h2 * (y2 - y1) / d;
  p4Y = p2Y - h2 * (x2 - x1) / d;

  return true;

}

//------------------------ TwoCirclesIntersectionArea --------------------
//
//  Tests to see if two circles overlap and if so calculates the area
//  defined by the union
//
// see http://mathforum.org/library/drmath/view/54785.html
//-----------------------------------------------------------------------
double TwoCirclesIntersectionArea(double x1, double y1, double r1,
                                  double x2, double y2, double r2)
{
  //first calculate the intersection points
  double iX1, iY1, iX2, iY2;

  if(!TwoCirclesIntersectionPoints(x1,y1,r1,x2,y2,r2,iX1,iY1,iX2,iY2))
  {
    return 0; //no overlap
  }

  //calculate the distance between the circle centers
  double d = sqrt( (x1-x2) * (x1-x2) + (y1-y2) * (y1-y2));

  //find the angles given that A and B are the two circle centers
  //and C and D are the intersection points
  double CBD = 2 * acos((r2*r2 + d*d - r1*r1) / (r2 * d * 2)); 

  double CAD = 2 * acos((r1*r1 + d*d - r2*r2) / (r1 * d * 2));


  //Then we find the segment of each of the circles cut off by the 
  //chord CD, by taking the area of the sector of the circle BCD and
  //subtracting the area of triangle BCD. Similarly we find the area
  //of the sector ACD and subtract the area of triangle ACD.

  double area = 0.5*CBD*r2*r2 - 0.5*r2*r2*sin(CBD) +
                0.5*CAD*r1*r1 - 0.5*r1*r1*sin(CAD);

  return area;
}

//
double CircleArea(double radius)
{
  return pi * radius * radius;
}




