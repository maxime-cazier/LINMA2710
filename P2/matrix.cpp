#include "matrix.hpp"
#include <iostream>
#include <vector>
#include <functional>


Matrix::Matrix(int n_rows, int n_cols){
    rows = n_rows;
    cols = n_cols;
    data = std::vector<double>(rows * cols, 0.0);
}


Matrix::Matrix(const Matrix &other){
    rows = other.rows;
    cols = other.cols;
    data = other.data;
}


double Matrix::get(int i, int j) const{
    return data[i * cols + j];
}

void Matrix::set(int i, int j, double value){
    data[i * cols + j] = value;
}


int Matrix::numRows() const{
    return rows;
}


int Matrix::numCols() const{
    return cols;
}


void Matrix::fill(double value){
    for(int i = 0; i < rows*cols; i++){
        data[i] = value;
    }
}

Matrix Matrix::operator+(const Matrix &other) const{
    Matrix m(rows, cols);
    for(int i = 0; i < rows; i++){
        for(int j = 0; j < cols; j++){
            m.set(i,j, data[i * cols + j] + other.get(i,j));
        }
    }
    return m;
}

Matrix Matrix::operator*(double scalar) const{
    Matrix m(rows, cols);
    for(int i = 0; i < rows; i++){
        for(int j = 0; j < cols; j++){
            m.set(i,j, data[i * cols + j]*scalar);
        }
    }
    return m;
}

Matrix Matrix::operator-(const Matrix &other) const{
    return *this + (other * -1);
}

// PREMIERE VERSION
//Matrix Matrix::operator*(const Matrix &other) const{
//    Matrix m(rows, other.numCols());
//    for(int i = 0; i < rows; i++){
//        for(int j = 0; j < other.numCols(); j++){
//            double sum = 0;
//            for(int k = 0; k < cols; k++){
//                sum += data[i * cols + k] * other.get(k,j);
//            }
//            m.set(i,j,sum);
//        }
//    }
//    return m;
//}
// PROBLEME :
// Problème de cache avec la matrice other vu que l'on accède à ses éléments de manière non contiguë
// Temps d'execution moyen (sur 20 echantillions) pour une matrice 500x500 : 858 ms

//DEUXIEME VERSION
Matrix Matrix::operator*(const Matrix &other) const{
    Matrix m(rows, other.numCols());
    Matrix otherT = other.transpose();
    for(int i = 0; i < rows; i++){
        for(int j = 0; j < other.numCols(); j++){
            double sum = 0;
            for(int k = 0; k < cols; k++){
                sum += data[i * cols + k] * otherT.get(j,k);
            }
            m.set(i,j,sum);
        }
    }
    return m;
}
//Bien qu'un peu meilleur, cette version presente les mêmes problèmes de cache
// Temps d'execution moyen (sur 20 echantillions) pour une matrice 500x500 : 771 ms





Matrix Matrix::transpose() const{
    Matrix m(cols, rows);
    for(int i = 0; i < rows; i++){
        for(int j = 0; j < cols; j++){
            m.set(j,i, data[i * cols + j]);
        }
    }
    return m;
}

Matrix Matrix::apply(const std::function<double(double)> &func) const{
    Matrix m(rows, cols);
    for(int i = 0; i < rows; i++){
        for(int j = 0; j < cols; j++){
            m.set(i,j, func(data[i * cols + j]));
        }
    }
    return m;
}


void Matrix::sub_mul(double scalar, const Matrix &other){
    *this = *this + other * ((-1)*scalar);
}

