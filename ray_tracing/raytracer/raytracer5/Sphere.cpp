//
// Created by Jamie Fox on 06/02/2016.
//

#include <math.h>

#include "Sphere.h"

Sphere::Sphere(const Vector3D &c,
               float r,
               const Colour &sc,
               float d, float s) :
        centre(c), radius(r), radius2(r * r), surfaceColour(sc), kd(d), ks(s) {}

Sphere::Sphere(const Vector3D &c,
               float r,
               const Colour &sc, const Colour &ec) :
        centre(c), radius(r), radius2(r * r), surfaceColour(sc), emissionColour(ec) {}

bool Sphere::intersect(const Vector3D &rayOrig, const Vector3D &rayDir, float &t0) const {
    Vector3D l = centre - rayOrig;

    float tca = l.dot(rayDir);

    if (tca < 0) {
        return false;
    }

    float d2 = l.dot(l) - tca * tca;

    if (d2 > radius2) {
        return false;
    }

    float thc = sqrtf(radius2 - d2);
    t0 = tca - thc;

    return true;
}
