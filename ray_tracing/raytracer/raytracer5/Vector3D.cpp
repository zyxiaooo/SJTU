//
// Created by Jamie Fox on 06/02/2016.
//

#include <math.h>
#include "Vector3D.h"

Vector3D::Vector3D(float xx, float yy, float zz) : x(xx), y(yy), z(zz) {}

float Vector3D::length() {
    return sqrtf(x * x + y * y + z * z);
}

Vector3D &Vector3D::norm() {
    float len = length();

    if (len > 0) {
        x /= len, y /= len, z /= len;
    }

    return *this;
}

float Vector3D::dot(const Vector3D &rhs) const {
    return x * rhs.x + y * rhs.y + z * rhs.z;
}

Vector3D &Vector3D::operator+=(const Vector3D &rhs) {
    x += rhs.x, y += rhs.y, z += rhs.z;
    return *this;
}

Vector3D &Vector3D::operator-=(const Vector3D &rhs) {
    x -= rhs.x, y -= rhs.y, z -= rhs.z;
    return *this;
}

Vector3D &Vector3D::operator*=(const float rhs) {
    x *= rhs, y *= rhs, z *= rhs;
    return *this;
}

Vector3D Vector3D::operator-() const {
    return Vector3D(-x, -y, -z);
}
