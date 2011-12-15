//
//  GLKMatrix3.c
//  GLKit Implementation
//
//  Created by Kenghoo Chuah on 12/9/11.
//  Copyright (c) 2011 Onpech.net. All rights reserved.
//

#include <float.h>
#include <GLKit/GLKMatrix3.h>

const GLKMatrix3 GLKMatrix3Identity = { 1.0f, 0.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 0.0f, 1.0f };

GLKMatrix3 GLKMatrix3Invert(GLKMatrix3 matrix, bool *isInvertible) {
    // m = transposed cofactor matrix
    GLKMatrix3 m = {
        matrix.m[4] * matrix.m[8] - matrix.m[5] * matrix.m[7], // c0
        matrix.m[2] * matrix.m[7] - matrix.m[1] * matrix.m[8], // c3
        matrix.m[1] * matrix.m[5] - matrix.m[2] * matrix.m[4], // c6
        0.0f, // c1
        0.0f, // c4
        0.0f, // c7
        0.0f, // c2
        0.0f, // c5
        0.0f  // c8
    };
    // d = matrix determinant
    float d = m.m[0] * matrix.m[0] + m.m[1] * matrix.m[3] + m.m[2] * matrix.m[6];
    if (fabsf(d) < FLT_EPSILON) {
        if(isInvertible) *isInvertible = false;
        return GLKMatrix3Identity;
    }
    if(isInvertible) *isInvertible = true;
    // d = 1 / matrix determinant
    d = 1.0f / d;
    // m = inverse matrix = transposed cofactor matrix * d
    m.m[0] *= d; // c0
    m.m[1] *= d; // c3
    m.m[2] *= d; // c6
    m.m[3] = (matrix.m[5] * matrix.m[6] - matrix.m[3] * matrix.m[8]) * d; // c1
    m.m[4] = (matrix.m[0] * matrix.m[8] - matrix.m[2] * matrix.m[6]) * d; // c4
    m.m[5] = (matrix.m[2] * matrix.m[3] - matrix.m[0] * matrix.m[5]) * d; // c7
    m.m[6] = (matrix.m[3] * matrix.m[7] - matrix.m[4] * matrix.m[6]) * d; // c2
    m.m[7] = (matrix.m[1] * matrix.m[6] - matrix.m[0] * matrix.m[7]) * d; // c5
    m.m[8] = (matrix.m[0] * matrix.m[4] - matrix.m[1] * matrix.m[3]) * d; // c8
    return m;
}

GLKMatrix3 GLKMatrix3InvertAndTranspose (GLKMatrix3 matrix, bool *isInvertible) {
    // m = cofactor matrix
    GLKMatrix3 m = {
        matrix.m[4] * matrix.m[8] - matrix.m[5] * matrix.m[7], // c0
        0.0f, // c1
        0.0f, // c2
        matrix.m[2] * matrix.m[7] - matrix.m[1] * matrix.m[8], // c3
        0.0f, // c4
        0.0f, // c5
        matrix.m[1] * matrix.m[5] - matrix.m[2] * matrix.m[4], // c6
        0.0f, // c7
        0.0f  // c8
    };
    // d = matrix determinant
    float d = m.m[0] * matrix.m[0] + m.m[3] * matrix.m[3] + m.m[6] * matrix.m[6];
    if (fabsf(d) < FLT_EPSILON) {
        if(isInvertible) *isInvertible = false;
        return GLKMatrix3Identity;
    }
    if(isInvertible) *isInvertible = true;
    // d = 1 / matrix determinant
    d = 1.0f / d;
    // m = transposed inverse matrix = cofactor matrix * d
    m.m[0] *= d; // c0
    m.m[1] = (matrix.m[5] * matrix.m[6] - matrix.m[3] * matrix.m[8]) * d; // c1
    m.m[2] = (matrix.m[3] * matrix.m[7] - matrix.m[4] * matrix.m[6]) * d; // c2
    m.m[3] *= d, // c3
    m.m[4] = (matrix.m[0] * matrix.m[8] - matrix.m[2] * matrix.m[6]) * d; // c4
    m.m[5] = (matrix.m[1] * matrix.m[6] - matrix.m[0] * matrix.m[7]) * d; // c5
    m.m[6] *= d; // c6
    m.m[7] = (matrix.m[2] * matrix.m[3] - matrix.m[0] * matrix.m[5]) * d; // c7
    m.m[8] = (matrix.m[0] * matrix.m[4] - matrix.m[1] * matrix.m[3]) * d; // c8
    return m;
}
