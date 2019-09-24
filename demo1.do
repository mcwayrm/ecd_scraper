#delim ;
version 12.1;
*
 Demonstrate the limiting Sidak-Bonferroni ratio
 of corrected p-value thresholds
 for infinite multiple comparisons
 and a range of input P-values.
 Output graphic files produced:
 demo1_1.eps
*;

clear all;
set scheme sj;

set obs 101;
gene punc=(_n-1)/(_N-1);
gene limprat=-ln(1-punc)/punc;
lab var punc "Uncorrected critical p-value";
lab var limprat "Limiting Sidak/Bonferroni corrected critical p-value ratio";
gsort -punc;
desc;
line limprat punc, xline(0.25 0.1 0.05 0.01,
  lpat(shortdash)) xscale(reverse)
  xlab(0.2(0.1)1 0.25 0.1 0.05 0.01);
graph export demo1_1.eps, replace;
more;
list;

exit;
