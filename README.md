# Wolfram-TensorNetwork

## Introduction

People have implemented numerical tensor network algorithms in many programming languages, such as MATLAB, Python, Julia. This project is intend to implement these algorithms in the Wolfram-Language.

Our code are based on this website: [Tensors.net](https://www.tensors.net/code). 

Currently, we have wrote the function ncon to deal with tensor contractions.

Though Mathematica have provided [built-in functions](https://reference.wolfram.com/language/guide/SymbolicTensors.html) to deal with symbolic tensors, they have not shown good performance in processing numerical tensor calculations. 

Here are 2 examples:

Example 1.


```mathematica
a = RandomReal[1, {1000}]; b = RandomReal[1, {1000, 1000}]; c = 
 RandomReal[1, {1000}];
```

```mathematica
NetworkContract[{a, b, c}, {{1}, {1, 2}, {2}}] == a . b . c

(*True*)
```

```mathematica
NetworkContract[{a, b, c}, {{1}, {1, 2}, {2}}] // AbsoluteTiming

(*{0.0023888, 125742.}*)
```

```mathematica
TensorContract[TensorProduct[a, b, c], {{1, 2}, {2, 3}}]
```

![1v6b4gdv4g6k0](https://raw.githubusercontent.com/weihongliang233/My-Markdown-Figures/master/20210719103200.png)

![0iamn8x4p6c2o](https://raw.githubusercontent.com/weihongliang233/My-Markdown-Figures/master/20210719103211.png)

```
(*SystemException["MemoryAllocationFailure"]*)
```

Example 2.

```mathematica
a = RandomReal[1, {2, 3, 4, 2, 2}]; b = RandomReal[1, {2, 3, 3}]; c = 
 RandomReal[1, {3, 2, 2, 2}]; d = RandomReal[1, {3, 3, 3, 3}];
e = RandomReal[1, {3, 2, 2, 2}];
```

```mathematica
NetworkContract[{a, b, c, d, 
   e}, {{1, -1, -2, 2, 1}, {2, -3, -4}, {-5, 3, 
    3, -6}, {-7, -8, -9, -10}, {-11, 4, 4, -12}}] == 
 TensorContract[
  TensorProduct[a, b, c, d, e], {{1, 5}, {4, 6}, {10, 11}, {18, 19}}]

(*True*)
```

```mathematica
AbsoluteTiming[
  NetworkContract[{a, b, c, d, 
    e}, {{1, -1, -2, 2, 1}, {2, -3, -4}, {-5, 3, 
     3, -6}, {-7, -8, -9, -10}, {-11, 4, 4, -12}}]][[1]]

(*0.005327*)
```

```mathematica
AbsoluteTiming[
  TensorContract[
   TensorProduct[a, b, c, d, 
    e], {{1, 5}, {4, 6}, {10, 11}, {18, 19}}]][[1]]

(*2.12144*)
```

```mathematica
NetworkContract[{a, b, c, d, 
   e}, {{2, -1, -2, 1, 2}, {1, -3, -4}, {-5, 4, 
    4, -6}, {-7, -8, -9, -10}, {-11, 3, 3, -12}}] == 
 TensorContract[
  TensorProduct[a, b, c, d, e], {{1, 5}, {4, 6}, {10, 11}, {18, 19}}]

(*True*)
```

## Installation

Currently, the code is stored in one single file `TensorNetwork.wl`. Import it and you can use the functions.

```mathematica
<<"TensorNetwork.wl"
```

## Author

The `ncon` is mainly developed by XiaMing Zheng. (He is not very familiar with the use of git, so he authorized me to publish it using my account).

