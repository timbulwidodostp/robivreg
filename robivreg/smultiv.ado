program define smultiv, eclass

* S-multivariate fit

version 10.0

if replay()& "`e(cmd)'"=="smultiv" {
ereturn  display
exit
}

syntax varlist [if] [in], [Generate(string) dummies(varlist) nreps(numlist max=1)]

tempvar touse
tempname id C S mu nr nrep
mark `touse' `if' `in'
markout `touse' `varlist' 

gen `id'=_n
local idi="`id'"

foreach var of varlist `varlist' {
qui reg `var' `dummies'
if e(r2)==1 {
di in r "some dummies are perfectly collinear with some continuous variables"
exit 198
}
}

_rmcoll `varlist'
local varlist=("`r(varlist)'")

_rmcoll `dummies'
local dummies=("`r(varlist)'")

if "`nreps'"!="" {
scalar nreps=`nreps'
}

else {
scalar nreps=0
}

mata: smult("`varlist'","`dummies'","`touse'","`idi'")

tokenize `varlist'
matrix `C'=r(C)
matrix `S'=r(S)
matrix `mu'=r(mu)

matrix rownames `C' = `varlist' `dummies'
matrix colnames `C' = `varlist' `dummies'

matrix rownames `S' = `varlist' `dummies'
matrix colnames `S' = `varlist' `dummies'

matrix colnames `mu' = `varlist' `dummies'
matrix rownames `mu'="location"

ereturn clear

ereturn matrix C =`C'
ereturn matrix S =`S'
ereturn matrix mu =`mu'


if "`generate'"!="" {
	tokenize `"`generate'"'
	local nw: word count `generate'

	if `nw'==2 {  
		local marker `1'
		local Dvar `2'
		confirm new var `marker' `Dvar'
	}

	else {
	di in r "define 2 variables in option generate"
	exit 198
	}
}
if "`generate'"!="" {
rename `d' `Dvar'
rename `outlier' `marker'
}


end


version 10.0
mata:
void smult(string scalar varlist, string scalar dummies, string scalar touse, string scalar idi)
{
st_view(X=.,.,tokens(varlist),touse)
st_view(D=.,.,tokens(dummies),touse)
st_view(Z=.,.,tokens(varlist))
st_view(Z2=.,.,tokens(dummies))
st_view(id=.,.,tokens(idi),touse)
nreps = st_numscalar("nreps")

n=rows(X)
detS=1e+25 
detSfin=1e+25
detS0=detS
diffA=1e+25
detA=1e+25
detB=1e+24
det0=0
err=1e+25
d0=J(n,1,1)
n2=floor(n/2)

w=d0
psi=d0
v=cols(X)

c=v*(sqrt((1/9)*(2/v))*(1.546)+(1-(1/9)*(2/v)))^3
c=sqrt(c)

if (nreps==0) {

	if (n>500) {
	nrep=(ceil((log(1-0.999))/(log(1-(1-0.25)^(v)))),1000)
	nrep=max(nrep)
	}

	else {
	nrep=5000
	}
	
}

else {
nrep=nreps
}

if (nrep==1) {
mu= mean(X, 1)
S = (1/n)*(X:-mu)'*(X:-mu)
}

else {
for (k=1;k<=nrep;k++) {
coll=1
det0=0
v0=v-1
while (det0==0) {

	v0=v0+1
	coll=1
	
			while (coll!=0){
			C=ceil(runiform((v0+1),1):*(n-1):+1)
			coll=length(uniqrows(C))-length(C)
			}
			
			means0 = mean(X[C,], 1)
			
			S0 = (1/(v0))*(X[C,]:-means0)'*(X[C,]:-means0)

				if ((det(S0)<detS)&(det(S0)!=0)) {
						S=S0
						mu=means0
						detS=det(S0)
				}
				det0=det(S0)
	}
}
}

	for (i=1; i<=rows(X); i++) {
    d0[i,1]=sqrt((X[i,]-mu)*invsym(S)*(X[i,]-mu)')
    }

j=1
d=d0
dX=(d,X,id)

while(err>1e-250&j<1000) {
          dX=sort(dX,1)

          means=mean(dX[1..(n2),2..(cols(dX)-1)])
          S = (1/(n/2))*(dX[1..(n2),2..(cols(dX)-1)]:-means)'*(dX[1..(n2),2..(cols(dX)-1)]:-means)     
			 
			 for (i=1; i<=rows(dX); i++) {
          d[i,1]=sqrt((dX[i,2..(cols(dX)-1)]-means)*invsym(S)*(dX[i,2..(cols(dX)-1)]-means)')
          }
			err=abs((detS/det(S))-1)
         detS=det(S)
			j=j+1
}

z=cols(dX)
dX=sort(dX,z)

d=dX[,1]


rho=((d:^2):/2-(d:^4)/(2*c^2)+(d:^6):/(6*(c^4))):*(abs(d):<=c)+((c^2)/6):*(abs(d):>c)
b0=(v*chi2(v+2,c^2)/2)-(v*(v+2)*chi2(v+4,c^2)/(2*(c^2)))+(v*(v+2)*(v+4)*chi2(v+6,c^2)/(6*(c^4)))+((c^2)/6)*(1-chi2(v,c^2))

rhop=mean(rho)

l=0

X=(X,D)
n=rows(X)
v=cols(X)

c=v*(sqrt((1/9)*(2/v))*(1.546)+(1-(1/9)*(2/v)))^3
c=sqrt(c)

b0=(v*chi2(v+2,c^2)/2)-(v*(v+2)*chi2(v+4,c^2)/(2*(c^2)))+(v*(v+2)*(v+4)*chi2(v+6,c^2)/(6*(c^4)))+((c^2)/6)*(1-chi2(v,c^2))


while ((abs((rhop/b0)-1)>1e-10|diffA>1e-10)&l<100) {
		rho=((d:^2):/2-(d:^4)/(2*c^2)+(d:^6):/(6*(c^4))):*(abs(d):<=c)+((c^2)/6):*(abs(d):>c)
		rhop=mean(rho)
	

		psi=(6/(c^2))*(d:*(1:-(d/c):^2):^2):*(abs(d:<c))
      w=psi:/d

		wX=w:*X
      mu=colsum(wX):/sum(w)
		S=J(v,v,0)
		for (j=1;j<=n;j++) {
				S=v*(w[j,])*((X[j,]-mu)'*(X[j,]-mu))+S

		}
		
		S=S/sum(psi:*d)
		S=S*((rhop/b0))	

      for (i=1; i<=rows(d); i++) {
      		d[i,1]=sqrt((X[i,]:-mu)*invsym(S)*(X[i,]:-mu)')
          }

      detB=det(S)
      diffA=(detB-detA)
      detA=det(S)

l=l+1
}
C=S:/((sqrt(diagonal(S))*(sqrt(diagonal(S)))'))

st_rclear()

st_matrix("r(C)", C)
st_matrix("r(S)", S)
st_matrix("r(mu)", mu)

d=J(rows(Z),1,1)

Z=(Z,Z2)

for (i=1; i<=rows(d); i++) {
		d[i,1]=sqrt((Z[i,]-mu)*invsym(S)*((Z[i,]-mu)'))
}



out=(d:>sqrt(invchi2(v,0.95)))
out=(out:/d):*d



idx = st_addvar("float",st_tempname())
st_store((1,rows(d)),idx,d)
st_local("d",st_varname(idx))

idx = st_addvar("float",st_tempname())
st_store((1,rows(out)),idx,out)
st_local("outlier",st_varname(idx))

}


end

exit

