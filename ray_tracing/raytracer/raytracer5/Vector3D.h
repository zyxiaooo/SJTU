//
// Created by Jamie Fox on 06/02/2016.
//

#ifndef RAY_TRACER_VECTOR3D_H
#define RAY_TRACER_VECTOR3D_H


class Vector3D {
public:
    float x, y, z;

    Vector3D(float xx, float yy, float zz);

    float length();

    Vector3D &norm();

    float dot(const Vector3D &rhs) const;

    Vector3D &operator+=(const Vector3D &rhs);
    Vector3D &operator-=(const Vector3D &rhs);
    Vector3D &operator*=(const float rhs);
    Vector3D operator-() const;
};

inline Vector3D operator+(Vector3D lhs, const Vector3D &rhs) {
    lhs += rhs;
    return lhs;
}

inline Vector3D operator-(Vector3D lhs, const Vector3D &rhs) {
    lhs -= rhs;
    return lhs;
}

inline Vector3D operator*(Vector3D lhs, const float rhs) {
    lhs *= rhs;
    return lhs;
}


#endif //RAY_TRACER_VECTOR3D_H
