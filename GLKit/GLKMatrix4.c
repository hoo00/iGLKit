//
//  GLKMatrix4.c
//  GLKit Implementation
//
//  Created by Kenghoo Chuah on 12/9/11.
//  Copyright (c) 2011 Onpech.net. All rights reserved.
//

#include <float.h>
#include <GLKit/GLKMatrix4.h>

const GLKMatrix4 GLKMatrix4Identity = { 1.0f, 0.0f, 0.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 0.0f, 0.0f, 1.0f };

GLKMatrix4 GLKMatrix4Invert(GLKMatrix4 matrix, bool *isInvertible) {
    // m = transposed cofactor matrix
    float c02070306 = matrix.m[2] * matrix.m[7] - matrix.m[3] * matrix.m[6];
    float c02110310 = matrix.m[2] * matrix.m[11] - matrix.m[3] * matrix.m[10];
    float c02150314 = matrix.m[2] * matrix.m[15] - matrix.m[3] * matrix.m[14];
    float c06110710 = matrix.m[6] * matrix.m[11] - matrix.m[7] * matrix.m[10];
    float c06150714 = matrix.m[6] * matrix.m[15] - matrix.m[7] * matrix.m[14];
    float c10151114 = matrix.m[10] * matrix.m[15] - matrix.m[11] * matrix.m[14];
    GLKMatrix4 m = {
        matrix.m[5] * c10151114 + matrix.m[9] * -c06150714 + matrix.m[13] * c06110710, // c0
        -matrix.m[1] * c10151114 + matrix.m[9] * c02150314 - matrix.m[13] * c02110310, // c4
        matrix.m[1] * c06150714 - matrix.m[5] * c02150314 + matrix.m[13] * c02070306, // c8
        -matrix.m[1] * c06110710 + matrix.m[5] * c02110310 - matrix.m[9] * c02070306, // c12
        0.0f, // c1
        0.0f, // c5
        0.0f, // c9
        0.0f, // c13
        0.0f, // c2
        0.0f, // c6
        0.0f, // c10
        0.0f, // c14
        0.0f, // c3
        0.0f, // c7
        0.0f, // c11
        0.0f, // c15
    };
    // d = matrix determinant
    float d = m.m[0] * matrix.m[0] + m.m[1] * matrix.m[4] + m.m[2] * matrix.m[8] + m.m[3] * matrix.m[12];
    if (fabsf(d) < FLT_EPSILON) {
        if(isInvertible) *isInvertible = false;
        return GLKMatrix4Identity;
    }
    if(isInvertible) *isInvertible = true;
    // d = 1 / matrix determinant
    d = 1.0f / d;
    // m = transposed inverse matrix = transposed cofactor matrix * d
    float c01070305 = matrix.m[1] * matrix.m[7] - matrix.m[3] * matrix.m[5];
    float c01110309 = matrix.m[1] * matrix.m[11] - matrix.m[3] * matrix.m[9];
    float c01150313 = matrix.m[1] * matrix.m[15] - matrix.m[3] * matrix.m[13];
    float c05110709 = matrix.m[5] * matrix.m[11] - matrix.m[7] * matrix.m[9];
    float c05150713 = matrix.m[5] * matrix.m[15] - matrix.m[7] * matrix.m[13];
    float c09151113 = matrix.m[9] * matrix.m[15] - matrix.m[11] * matrix.m[13];
    
    float c01060205 = matrix.m[1] * matrix.m[6] - matrix.m[2] * matrix.m[5];
    float c01100209 = matrix.m[1] * matrix.m[10] - matrix.m[2] * matrix.m[9];
    float c01140213 = matrix.m[1] * matrix.m[14] - matrix.m[2] * matrix.m[13];
    float c05100609 = matrix.m[5] * matrix.m[10] - matrix.m[6] * matrix.m[9];
    float c05140613 = matrix.m[5] * matrix.m[14] - matrix.m[6] * matrix.m[13];
    float c09141013 = matrix.m[9] * matrix.m[14] - matrix.m[10] * matrix.m[13];
    
    m.m[0] *= d; // c0
    m.m[1] *= d, // c4
    m.m[2] *= d; // c8
    m.m[3] *= d; // c12
    m.m[4] = (-matrix.m[4] * c10151114 + matrix.m[8] * c06150714 - matrix.m[12] * c06110710) * d; // c1
    m.m[5] = (matrix.m[0] * c10151114 - matrix.m[8] * c02150314 + matrix.m[12] * c02110310) * d; // c5
    m.m[6] = (-matrix.m[0] * c06150714 + matrix.m[4] * c02150314 - matrix.m[12] * c02070306) * d; // c9
    m.m[7] = (matrix.m[0] * c06110710 - matrix.m[4] * c02110310 + matrix.m[8] * c02070306) * d; // c13
    m.m[8] = (matrix.m[4] * c09151113 - matrix.m[8] * c05150713 + matrix.m[12] * c05110709) * d; // c2
    m.m[9] = (-matrix.m[0] * c09151113 + matrix.m[8] * c01150313 - matrix.m[12] * c01110309) * d; // c6
    m.m[10] = (matrix.m[0] * c05150713 - matrix.m[4] * c01150313 + matrix.m[12] * c01070305) * d; // c10
    m.m[11] = (-matrix.m[0] * c05110709 + matrix.m[4] * c01110309 - matrix.m[8] * c01070305) * d; // c14
    m.m[12] = (-matrix.m[4] * c09141013 + matrix.m[8] * c05140613 - matrix.m[12] * c05100609) * d; // c3
    m.m[13] = (matrix.m[0] * c09141013 - matrix.m[8] * c01140213 + matrix.m[12] * c01100209) * d; // c7
    m.m[14] = (-matrix.m[0] * c05140613 + matrix.m[4] * c01140213 - matrix.m[12] * c01060205) * d; // c11
    m.m[15] = (matrix.m[0] * c05100609 - matrix.m[4] * c01100209 + matrix.m[8] * c01060205) * d; // c15
    return m;
}

GLKMatrix4 GLKMatrix4InvertAndTranspose(GLKMatrix4 matrix, bool *isInvertible) {
    // m = cofactor matrix
    float c02070306 = matrix.m[2] * matrix.m[7] - matrix.m[3] * matrix.m[6];
    float c02110310 = matrix.m[2] * matrix.m[11] - matrix.m[3] * matrix.m[10];
    float c02150314 = matrix.m[2] * matrix.m[15] - matrix.m[3] * matrix.m[14];
    float c06110710 = matrix.m[6] * matrix.m[11] - matrix.m[7] * matrix.m[10];
    float c06150714 = matrix.m[6] * matrix.m[15] - matrix.m[7] * matrix.m[14];
    float c10151114 = matrix.m[10] * matrix.m[15] - matrix.m[11] * matrix.m[14];
    GLKMatrix4 m = {
        matrix.m[5] * c10151114 + matrix.m[9] * -c06150714 + matrix.m[13] * c06110710, // c0
        0.0f, // c1
        0.0f, // c2
        0.0f, // c3
        -matrix.m[1] * c10151114 + matrix.m[9] * c02150314 - matrix.m[13] * c02110310, // c4
        0.0f, // c5
        0.0f, // c6
        0.0f, // c7
        matrix.m[1] * c06150714 - matrix.m[5] * c02150314 + matrix.m[13] * c02070306, // c8
        0.0f, // c9
        0.0f, // c10
        0.0f, // c11
        -matrix.m[1] * c06110710 + matrix.m[5] * c02110310 - matrix.m[9] * c02070306, // c12
        0.0f, // c13
        0.0f, // c14
        0.0f, // c15
    };
    // d = matrix determinant
    float d = m.m[0] * matrix.m[0] + m.m[4] * matrix.m[4] + m.m[8] * matrix.m[8] + m.m[12] * matrix.m[12];
    if (fabsf(d) < FLT_EPSILON) {
        if(isInvertible) *isInvertible = false;
        return GLKMatrix4Identity;
    }
    if(isInvertible) *isInvertible = true;
    // d = 1 / matrix determinant
    d = 1.0f / d;
    // m = transposed inverse matrix = cofactor matrix * d
    float c01070305 = matrix.m[1] * matrix.m[7] - matrix.m[3] * matrix.m[5];
    float c01110309 = matrix.m[1] * matrix.m[11] - matrix.m[3] * matrix.m[9];
    float c01150313 = matrix.m[1] * matrix.m[15] - matrix.m[3] * matrix.m[13];
    float c05110709 = matrix.m[5] * matrix.m[11] - matrix.m[7] * matrix.m[9];
    float c05150713 = matrix.m[5] * matrix.m[15] - matrix.m[7] * matrix.m[13];
    float c09151113 = matrix.m[9] * matrix.m[15] - matrix.m[11] * matrix.m[13];
    
    float c01060205 = matrix.m[1] * matrix.m[6] - matrix.m[2] * matrix.m[5];
    float c01100209 = matrix.m[1] * matrix.m[10] - matrix.m[2] * matrix.m[9];
    float c01140213 = matrix.m[1] * matrix.m[14] - matrix.m[2] * matrix.m[13];
    float c05100609 = matrix.m[5] * matrix.m[10] - matrix.m[6] * matrix.m[9];
    float c05140613 = matrix.m[5] * matrix.m[14] - matrix.m[6] * matrix.m[13];
    float c09141013 = matrix.m[9] * matrix.m[14] - matrix.m[10] * matrix.m[13];
    
    m.m[0] *= d; // c0
    m.m[1] = (-matrix.m[4] * c10151114 + matrix.m[8] * c06150714 - matrix.m[12] * c06110710) * d; // c1
    m.m[2] = (matrix.m[4] * c09151113 - matrix.m[8] * c05150713 + matrix.m[12] * c05110709) * d; // c2
    m.m[3] = (-matrix.m[4] * c09141013 + matrix.m[8] * c05140613 - matrix.m[12] * c05100609) * d; // c3
    m.m[4] *= d, // c4
    m.m[5] = (matrix.m[0] * c10151114 - matrix.m[8] * c02150314 + matrix.m[12] * c02110310) * d; // c5
    m.m[6] = (-matrix.m[0] * c09151113 + matrix.m[8] * c01150313 - matrix.m[12] * c01110309) * d; // c6
    m.m[7] = (matrix.m[0] * c09141013 - matrix.m[8] * c01140213 + matrix.m[12] * c01100209) * d; // c7
    m.m[8] *= d; // c8
    m.m[9] = (-matrix.m[0] * c06150714 + matrix.m[4] * c02150314 - matrix.m[12] * c02070306) * d; // c9
    m.m[10] = (matrix.m[0] * c05150713 - matrix.m[4] * c01150313 + matrix.m[12] * c01070305) * d; // c10
    m.m[11] = (-matrix.m[0] * c05140613 + matrix.m[4] * c01140213 - matrix.m[12] * c01060205) * d; // c11
    m.m[12] *= d; // c12
    m.m[13] = (matrix.m[0] * c06110710 - matrix.m[4] * c02110310 + matrix.m[8] * c02070306) * d; // c13
    m.m[14] = (-matrix.m[0] * c05110709 + matrix.m[4] * c01110309 - matrix.m[8] * c01070305) * d; // c14
    m.m[15] = (matrix.m[0] * c05100609 - matrix.m[4] * c01100209 + matrix.m[8] * c01060205) * d; // c15
    return m;
}