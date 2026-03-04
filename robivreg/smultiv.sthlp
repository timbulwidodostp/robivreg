{smcl}
{* *! version 1.0.0}{...}
{cmd:help smultiv}{right: ({browse "http://www.stata-journal.com/article.html?article=st0259":SJ12-2: st0259})}
{hline}

{title:Title}

{p2colset 5 16 22 2}{...}
{p2col :{hi:smultiv} {hline 2}}S-estimator of multivariate location and scatter{p_end}
{p2colreset}{...}


{title:Syntax}

{p 8 20 2}
{cmd:smultiv} 
{varlist} 
{ifin}
[{cmd:,} {it:options}] 

{synoptset 30}{...}
{synopthdr}
{synoptline}
{synopt :{opt g:enerate(varname1 varname2)}}create {it:varname1}, a dummy that flags outliers, and {it:varname2}, the robust Mahalanobis distances{p_end}
{synopt :{opt dummies(varlist)}}specify the dummy variables{p_end}
{synopt :{opt nreps(#)}}specify the number of replications{p_end}
{synoptline}


{title:Description}

{pstd}
{cmd:smultiv} computes the S-estimator of multivariate location and scatter, as
well as the robust correlation matrix.


{title:Options}

{phang}
{opt generate(varname1 varname2)} creates two new variables:
{it:varname1}, a dummy variable that flags the outliers, and
{it:varname2}, a continuous variable that reports the robust Mahalanobis
distances.  The user must specify the name for each of the variables generated.
These variables cannot be generated separately.

{phang}
{opt dummies(varlist)} specifies the dummy variables in the dataset.

{phang}
{opt nreps(#)} specifies the number of replications.


{title:Example}

{pstd}Setup{p_end}
{phang2}{cmd:. use http://homepages.ulb.ac.be/~vverardi/unidata}{p_end}

{pstd}Compute S-estimates of multivariate location and scatter{p_end}
{phang2}{cmd:. smultiv score cost enrol math undergrad,}
      {cmd:generate(outlier RobustDistance) dummies(private)}{p_end}

{pstd}Display the S-estimator of the location vector, scatter matrix, and
robust correlation matrix{p_end}
{phang2}{cmd:. matrix list e(mu)}{p_end}
{phang2}{cmd:. matrix list e(S)}{p_end}
{phang2}{cmd:. matrix list e(C)}{p_end}


{title:Saved results}

{pstd}
{cmd:smultiv} saves the following in {cmd:e()}:

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Matrices}{p_end}
{synopt:{cmd:e(mu)}}location vector{p_end}
{synopt:{cmd:e(S)}}scatter matrix{p_end}
{synopt:{cmd:e(C)}}robust correlation matrix{p_end}


{title:Also see}

{p 4 14 2}Article:  {it:Stata Journal}, volume 12, number 2: {browse "http://www.stata-journal.com/article.html?article=st0259":st0259}

{p 7 14 2}
Help:  {manhelp qreg R}, {manhelp regress R};{break}
{manhelp rreg R}, {helpb mmregress}, {helpb sregress}, {helpb msregress}, 
{helpb mregress}, {helpb mcd} (if installed){p_end}
