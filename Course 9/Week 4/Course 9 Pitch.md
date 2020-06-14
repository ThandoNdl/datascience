<style>
.footer {
    color: black;
    background: #E8E8E8;
    position: fixed;
    top: 90%;
    text-align:center;
    width:100%;
}
</style>

Mortgage Payment Calculator
========================================================
author: NN
date: June 2020
autosize: true

What is it
========================================================

This is a calculator that can help you determine the monthly payment amount of a mortgage loan based on the loan amount, chosen term and interest rate.

Please note:
This calculator serves as an indication only as loans are often subject to the terms and policies of the instituion offering the loan which will have it's service fees not factored into this calculation.
We therefore cannot be held liable for any inaccuracies.

Which inputs and results
========================================================

### Input
- Loan amount (must be greater than 0)
- Loan term (must be greater than 0)
- Interest Rate
- Which month you would like the amortization table view to begin (must be greater than 0)

### Results
- Monthly mortgage payments
- Total payment for the loan
- Amount of total interest payments
- A 12 month view of the amortization table
    If the input for the beginning month for the view
    is within the last 12 months of the loan term, it      will only return the remaining months
- A graph showing how the balance changes and amount paid with respect to time


Example
========================================================

Suppose you are enquiring about a 100 000 mortgage which will be repaid over 360 months with an interest rate of 6%.


```r
library(FinancialMath)
stats = amort.table(Loan=100000,
            n=360,
            pmt=NA,
            i=0.06,
            ic=12,
            pf=12,plot=FALSE)
```

Example (cont.)
========================================================

Results


```r
stats$Schedule[1:5,]
```

```
  Year Payment Interest Paid Principal Paid  Balance
1 0.08  599.55        500.00          99.55 99900.45
2 0.17  599.55        499.50         100.05 99800.40
3 0.25  599.55        499.00         100.55 99699.85
4 0.33  599.55        498.50         101.05 99598.80
5 0.42  599.55        497.99         101.56 99497.24
```
