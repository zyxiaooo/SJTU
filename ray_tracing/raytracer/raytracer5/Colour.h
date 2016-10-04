//
// Created by Jamie Fox on 06/02/2016.
//

#ifndef RAY_TRACER_COLOUR_H
#define RAY_TRACER_COLOUR_H


class Colour {
public:
    float red, green, blue;

    Colour(float r, float g, float b);
    Colour();

    Colour &operator+=(const Colour &rhs);
    Colour &operator-=(const Colour &rhs);
    Colour &operator*=(const Colour &rhs);
    Colour &operator*=(const float rhs);
};

inline Colour operator+(Colour lhs, const Colour &rhs) {
    lhs += rhs;
    return lhs;
}

inline Colour operator-(Colour lhs, const Colour &rhs) {
    lhs -= rhs;
    return lhs;
}

inline Colour operator*(Colour lhs, const Colour &rhs) {
    lhs *= rhs;
    return lhs;
}

inline Colour operator*(Colour lhs, const float rhs) {
    lhs *= rhs;
    return lhs;
}


#endif //RAY_TRACER_COLOUR_H
