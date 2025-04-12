#include "distributedmatrix.hpp"

DistributedMatrix::DistributedMatrix(const Matrix& matrix, int numProc){
    globalRows = matrix.numRows();
    globalCols = matrix.numCols();
    numProcesses = numProc;

    MPI_Comm_rank(MPI_COMM_WORLD, &rank);

    if (rank >= numProc - globalCols % numProc) {
        localCols = globalCols / numProc + 1;
        startCol = globalCols - (numProc - rank - 1) * localCols - 1;
    } else {
        localCols = globalCols / numProc;
        startCol = rank * localCols;
    }

    localData = Matrix(globalRows, localCols);

    for (int i = 0; i < globalRows; ++i) {
        for (int j = 0; j < localCols; ++j) {
            localData.get(i, j, matrix.get(i, startCol + j));
        }
    }
}


DistributedMatrix::DistributedMatrix(int globalR, int globalC, int localC, int startC, const Matrix& localDat){
    globalRows = globalR;
    globalCols = globalC;
    localCols = localC;
    startCol = startC;

    MPI_Comm_rank(MPI_COMM_WORLD, &rank);
    MPI_Comm_size(MPI_COMM_WORLD, &numProcesses);

    localData = localDat;
}


DistributedMatrix::DistributedMatrix(const DistributedMatrix& other){
      globalRows = other.globalRows;
      globalCols = other.globalCols;
      localCols = other.localCols;
      startCol = other.startCol;
      numProcesses = other.numProcesses;
      rank = other.rank;
      localData = other.localData; //Shallow copy
}


int DistributedMatrix::numRows() const {
    return globalRows;
}

int DistributedMatrix::numCols() const {
    return localCols;
}

double DistributedMatrix::get(int i, int j) const {
    return localData.get(i, j);
}

void DistributedMatrix::set(int i, int j, double value) {
    localData.set(i, j, value);
}

int DistributedMatrix::globalColIndex(int localColIndex) const {
    return startCol + localColIndex;
}

int DistributedMatrix::localColIndex(int globalColIndex) const {
    if (globalColIndex < startCol || globalColIndex >= startCol + localCols) {
        return -1;
    }
    return globalColIndex - startCol;
}

int DistributedMatrix::ownerProcess(int globalColIndex) const {
    return std::min(globalColIndex / (globalCols / numProcesses) , numProcesses - 1 - (globalCol - 1 - globalColIndex) / (globalCols / numProcesses + 1));
}

const Matrix& DistributedMatrix::getLocalData() const {
    return localData;
}

DistributedMatrix DistributedMatrix::apply(const std::function<double(double)> &func) const {
    Matrix result(globalRows, localCols);
    for (int i = 0; i < globalRows; ++i) {
        for (int j = 0; j < localCols; ++j) {
            result.set(i, j, func(get(i, j)));
        }
    }
    return DistributedMatrix(globalRows, globalCols, localCols, startCol, result);
}

DistributedMatrix DistributedMatrix::applyBinary(const DistributedMatrix& a,const DistributedMatrix& b,const std::function<double(double, double)> &func) {
    Matrix result(a.globalRows, a.localCols);
    for (int i = 0; i < a.globalRows; ++i) {
        for (int j = 0; j < a.localCols; ++j) {
            result.set(i, j, func(a.get(i, j), b.get(i, j)));
        }
    }
    return DistributedMatrix(a.globalRows, a.globalCols, a.localCols, a.startCol, result);
}


double DistributedMatrix::sum() const{
    double localSum = 0.0;
    for (int i = 0; i < localData.numRows(); ++i) {
        for (int j = 0; j < localData.numCols(); ++j) {
            localSum += matrix.get(i, j);
        }
    }

    double globalSum = 0.0;
    MPI_Reduce(&localSum, &globalSum, 1, MPI_DOUBLE, MPI_SUM, MPI_COMM_WORLD);
    return globalSum;
}

Matrix DistributedMatrix::gather() const {
    Matrix result(globalRows, globalCols);
    MPI_Gather(localData.data(), localData.numRows() * localData.numCols(), MPI_DOUBLE, result.data(), localData.numRows() * localData.numCols(), MPI_DOUBLE, 0, MPI_COMM_WORLD);
    return result;
}


DistributedMatrix multiply(const Matrix& left, const DistributedMatrix& right) {
    int globalRows = left.numRows();
    int globalCols = right.numCols();
    int localCols = right.localCols;
    int startCol = right.startCol;

    Matrix result = left * right.getLocalData();
    return DistributedMatrix(globalRows, globalCols, localCols, startCol, result);
}

Matrix DistributedMatrix::multiplyTransposed(const DistributedMatrix& other) const {
    double* data = new double[globalRows * other.globalRows];
    
}