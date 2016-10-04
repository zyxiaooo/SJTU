//
// Created by Jamie Fox on 06/02/2016.
//

#include "Colour.h"

Colour::Colour(float r, float g, float b) : red(r), blue(b), green(g) {}

Colour::Colour() : red(0), blue(0), green(0) {}

Colour &Colour::operator+=(const Colour &rhs) {
    red += rhs.red, green += rhs.green, blue += rhs.blue;
    return *this;
}

Colour &Colour::operator-=(const Colour &rhs) {
    red -= rhs.red, green -= rhs.green, blue -= rhs.blue;
    return *this;
}

Colour &Colour::operator*=(const Colour &rhs) {
    red *= rhs.red, green *= rhs.green, blue *= rhs.blue;
    return *this;
}

Colour &Colour::operator*=(const float rhs) {
    red *= rhs, green *= rhs, blue *= rhs;
    return *this;
}
