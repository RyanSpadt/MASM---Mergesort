# MASM---Mergesort
This is an implementation of the mergesort algorithm in 32 bit Irvine MASM. Written in Microsoft Visual Studio Community 2019 Version 16.4.4

The program takes an input unsorted array of integers (not accepted as input but declared in the .data section).
It then displays to the console a welcome message as well as the unsorted array. 
Using a stack frame it utilizes recursion to divide the array in half until the elements are singletons.
Then taking the singleton array elements it merges them back together sorted by pass merging and displays the sorted array to console.

![Example](mergesort example.png)
