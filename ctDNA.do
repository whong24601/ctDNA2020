clear all
import excel "Summary data for Wei.V2.xlsx", sheet("Sheet1") firstrow
drop if timetolastfollowupfromlive > 999999
destring timetolastfollowupor, replace
replace timetolastfollowupfromlive = timetolastfollowuporrecurr if JHUID == "LCR 308"

gen WHpostopctDNA = .
replace WHpostopctDNA = 1 if PostopctDNA == "Positive"
replace WHpostopctDNA = 0 if PostopctDNA == "Negative"
gen WHbaselinectDNAT0 = 0
replace WHbaselinectDNAT0 = 1 if BaselinectDNAT0 == "Positive"
gen WHbaselineCEA = 0
replace WHbaselineCEA = 1 if BaselineCEA == "Y"
gen WHmorethan1livermet = 0
replace WHmorethan1livermet = 1 if Noofliver > 1
gen WHmorethan3cm = 0
replace WHmorethan3cm = 1 if Diameter == "Y"
gen WHmorethan12m = 0
replace WHmorethan12m = 1 if Timefrom == "Y"
gen WHNstage = 1
replace WHNstage = 0 if Staging_N == "0"
gen WHRFS = timetolastfollowupor
gen WHRFSstatus = RecurrenceYes1
gen WHOS = timetolastfollowupfromlive
gen WHOSstatus = Deathstatus1dead
gen WHsex = 0
replace WHsex = 1 if Sex == "M"
gen WHsynchro = 0
replace WHsynchro = 1 if stageIVatdiag == "Y"
gen WHright = 0
replace WHright = 1 if PrimaryTumoursite == "Right"
gen WHN0 = 0
replace WHN0 = 1 if Staging_N == "0"
gen WHNmorethan0 = 1-WHN0
gen WHwellmod = 0 
replace WHwellmod = 1 if Differentiation == "Well-Mod" | Differentiation == "well-Mod"
gen WHpoor = 1-WHwellmod
gen WHpostopCEA = .
replace WHpostopCEA = 1 if PostopCEAelevated == "Y"
replace WHpostopCEA = 0 if PostopCEAelevated == "N"
gen WHR0 = .
replace WHR0 = 1 if resultofsurgery == "R0"
replace WHR0 = 0 if resultofsurgery == "R1"
gen WHRmorethan0 = 1-WHR0

di "BASELINE"
quietly {
	local WHvariable = "WHpostopctDNA" //"WHbaselinectDNAT0"
	di `" "`WHvariable'" :"'
	su Age if `WHvariable' == 1, d
	noisily di "pos AGE: " "MEDIAN = " round(r(p50),0.1) ", MIN = " round(r(min),0.1) ", MAX = " round(r(max),0.1) 
	su Age if `WHvariable' == 0, d
	noisily di "neg AGE: " "MEDIAN = " round(r(p50),0.1) ", MIN = " round(r(min),0.1) ", MAX = " round(r(max),0.1) 
	noisily ranksum Ageatenrolment, by(`WHvariable')
	
	foreach var in WHsex WHmorethan1livermet WHsynchro WHmorethan12m WHright WHNmorethan0 WHpoor WHbaselineCEA WHRmorethan0 WHpostopCEA {
		noisily di "pos: `var'"
		noisily tab `var' if `WHvariable' == 1
		noisily di "neg: `var'"
		noisily tab `var' if `WHvariable' == 0
		noisily prtest `var', by(`WHvariable')
	}
	
}

if (1 == 1) {
di "UNIVAR RFS"
stset WHRFS, failure(WHRFSstatus)
stcox WHpostopctDNA, exactp cformat(%9.2f) sformat(%9.2f) 
stcox WHbaselineCEA, exactp cformat(%9.2f) sformat(%9.2f)
stcox WHmorethan1livermet, exactp cformat(%9.2f) sformat(%9.2f)
stcox WHmorethan3cm, exactp cformat(%9.2f) sformat(%9.2f)
stcox WHmorethan12m, exactp cformat(%9.2f) sformat(%9.2f)
stcox WHNstage, exactp  cformat(%9.2f) sformat(%9.2f)
di "MULTIVAR RFS5"
stcox WHpostopctDNA WHbaselineCEA WHmorethan3cm WHmorethan12m WHNstage, exactp  cformat(%9.2f) sformat(%9.2f)

di "MULTIVAR RFS6"
stcox WHpostopctDNA WHbaselineCEA WHmorethan1livermet WHmorethan3cm WHmorethan12m WHNstage, exactp  cformat(%9.2f) sformat(%9.2f)
exit
di "UNIVAR OS"
stset WHOS, failure(WHOSstatus)
stcox WHpostopctDNA, exactp  cformat(%9.2f) sformat(%9.2f)
stcox WHbaselineCEA, exactp cformat(%9.2f) sformat(%9.2f)
stcox WHmorethan1livermet, exactp cformat(%9.2f) sformat(%9.2f)
stcox WHmorethan3cm, exactp cformat(%9.2f) sformat(%9.2f)
stcox WHmorethan12m, exactp cformat(%9.2f) sformat(%9.2f)
stcox WHNstage, exactp  cformat(%9.2f) sformat(%9.2f)
di "MULTIVAR OS5"
stcox WHpostopctDNA WHbaselineCEA WHmorethan3cm WHmorethan12m WHNstage, exactp  cformat(%9.2f) sformat(%9.2f)
di "MULTIVAR OS6"
stcox WHpostopctDNA WHbaselineCEA WHmorethan1livermet WHmorethan3cm WHmorethan12m WHNstage, exactp  cformat(%9.2f) sformat(%9.2f)
exit
}

if (1 == 1) {
	di "K-M"
	stset WHRFS, failure(WHRFSstatus)
	gen WHcleargroup = .
	replace WHcleargroup = 0 if BaselinectDNAT0 == "Negative"
	replace WHcleargroup = 1 if BaselinectDNAT0 == "Positive" & ctDNAclearan == "Y"
	replace WHcleargroup = 2 if BaselinectDNAT0 == "Positive" & PostNACC4_ctDNATC4 == "Positive"
	stcox i.WHcleargroup if Cohort == 2
	//matrix M = e(b)
	//local HR1 =  round(exp(M[1,2]),0.01)
	//local HR2 =  round(exp(M[1,3]),0.01)
	local HR1 = 5.49
	local L1 = "0.67"
	local U1 = 44.8
	local P1 =  "0.11"
	local HR2 = 4.75
	local L2 = "0.43"
	local U2 = 52.8
	local P2 = "0.21"
	sts graph if Cohort == 2, by(WHcleargroup) xlabels() legend(order(1 "Baseline negative: RFS60 = 1, baseline"  2 "Clearance at C2, 3 or 4: RFS60 = 0.42 (0.21 to 0.81), p = 0.009"  ///
	3 "No clearance at C4: RFS60 = 0.5 (0.19 to 1.00), p = 0.16" ) size(2.5) ///
	region(lcolor("0 0 0 %0") fcolor("0 0 0 %0")) pos(7) ring(0) cols(1)) xtitle("Time from surgery (months)") title("") ///
	ytitle("Recurrence-free survival") graphregion(fcolor("255 255 255") lcolor("255 255 255")) plotregion(margin(zero)) risktable(,order(1 "Baseline negative" 2 "Clearance at C2, 3 or 4" 3 "No clearance at C4")) ylabel(,angle(0)) ///
	plot1opts(lcolor("blue")) plot2opts(lcolor("green")) plot3opts(lcolor("red")) censored(single)
	graph export "Fig2d.png", as(png) replace
	exit
	gen WHendpos = .
	replace WHendpos = 0 if EndofalltreatmentctDNAstatu == "Negative"
	replace WHendpos = 1 if EndofalltreatmentctDNAstatu == "Positive"
	stcox i.WHendpos if PostopctDNATP == "Positive"
	local HR1 = 7.87
	local L1 = "0.95"
	local U1 = 63.7
	local P1 =  "= 0.056"

	sts graph if PostopctDNATP == "Positive", by(WHendpos) xlabels() legend(order(1 "Clearance" 2 "No clearance" - "HR `HR1' (`L1' to `U1'), p `P1'") region(lcolor("0 0 0 %0") fcolor("0 0 0 %0")) pos(5) ring(0) cols(1)) xtitle("Time from surgery (months)") title("") ///
	ytitle("Recurrence-free survival") graphregion(fcolor("255 255 255") lcolor("255 255 255")) plotregion(margin(zero)) risktable(,order(1 "Clearance" 2 "No clearance" )) ylabel(,angle(0)) ///
	plot1opts(lcolor("blue")) plot2opts(lcolor("red"))  censored(single)
	graph export "Fig3b.png", as(png) replace
	
	local l1 = "ctDNA-Negative"
	local l2 = "ctDNA-Positive"
	
	stcox i.WHbaselinectDNAT0
	local HR1 = 4.72
	local L1 = "0.63"
	local U1 = 35.1
	local P1 =  "= 0.13"
	sts graph, by(WHbaselinectDNAT0) xlabels() legend(order(1 "`l1'" 2 "`l2'" - "HR `HR1' (`L1' to `U1'), p `P1'") region(lcolor("0 0 0 %0") fcolor("0 0 0 %0")) pos(5) ring(0) cols(1)) xtitle("Time from surgery (months)") title("") ///
	ytitle("Recurrence-free survival") graphregion(fcolor("255 255 255") lcolor("255 255 255")) plotregion(margin(zero)) risktable(,order(1 "`l1'" 2 "`l2'" )) ylabel(,angle(0)) ///
	plot1opts(lcolor("blue")) plot2opts(lcolor("red"))  censored(single) title("Baseline")
	graph export "KMT0RFS.png", as(png) replace
	graph save Graph "11.gph", replace
	
	stcox i.WHpostopctDNA
	local HR1 = 6.26
	local L1 = 2.58
	local U1 = 15.2
	local P1 =  "< 0.001"
	sts graph, by(WHpostopctDNA) xlabels() legend(order( - "HR `HR1' (`L1' to `U1'), p `P1'") region(lcolor("0 0 0 %0") fcolor("0 0 0 %0")) pos(5) ring(0) cols(1)) xtitle("Time from surgery (months)") title("") ///
	ytitle("Recurrence-free survival") graphregion(fcolor("255 255 255") lcolor("255 255 255")) plotregion(margin(zero)) risktable(,order(1 "`l1'" 2 "`l2'" )) ylabel(,angle(0)) ///
	plot1opts(lcolor("blue")) plot2opts(lcolor("red"))  censored(single) title("Post-operative")
	graph export "KMTPRFS.png", as(png) replace
	graph save Graph "12.gph", replace

	stcox i.WHendpos
	local HR1 = 14.9
	local L1 = 4.94
	local U1 = 44.7
	local P1 =  "< 0.001"
	sts graph, by(WHendpos) xlabels() legend(order( - "HR `HR1' (`L1' to `U1'), p `P1'") region(lcolor("0 0 0 %0") fcolor("0 0 0 %0")) pos(5) ring(0) cols(1)) xtitle("Time from surgery (months)") title("") ///
	ytitle("Recurrence-free survival") graphregion(fcolor("255 255 255") lcolor("255 255 255")) plotregion(margin(zero)) risktable(,order(1 "`l1'" 2 "`l2'" )) ylabel(,angle(0)) ///
	plot1opts(lcolor("blue")) plot2opts(lcolor("red"))  censored(single) title("End of Treatment")
	graph export "KMTEOTRFS.png", as(png) replace
	graph save Graph "13.gph", replace

	stset WHOS, failure(WHOSstatus)
	
	stcox i.WHbaselinectDNAT0
	local HR1 = 1.39
	local L1 = "0.31"
	local U1 = 6.18
	local P1 =  "= 0.66"
	sts graph, by(WHbaselinectDNAT0) xlabels() legend(order( - "HR `HR1' (`L1' to `U1'), p `P1'") region(lcolor("0 0 0 %0") fcolor("0 0 0 %0")) pos(5) ring(0) cols(1)) xtitle("Time from surgery (months)") title("") ///
	ytitle("Overall survival") graphregion(fcolor("255 255 255") lcolor("255 255 255")) plotregion(margin(zero)) risktable(,order(1 "`l1'" 2 "`l2'" )) ylabel(,angle(0)) ///
	plot1opts(lcolor("blue")) plot2opts(lcolor("red"))  censored(single) title(" ")
	graph export "KMT0OS.png", as(png) replace
	graph save Graph "21.gph", replace
	
	stcox i.WHpostopctDNA
	local HR1 = 4.20
	local L1 = 1.50
	local U1 = 11.8
	local P1 =  "< 0.001"
	sts graph, by(WHpostopctDNA) xlabels() legend(order( - "HR `HR1' (`L1' to `U1'), p `P1'") region(lcolor("0 0 0 %0") fcolor("0 0 0 %0")) pos(5) ring(0) cols(1)) xtitle("Time from surgery (months)") title("") ///
	ytitle("Overall survival") graphregion(fcolor("255 255 255") lcolor("255 255 255")) plotregion(margin(zero)) risktable(,order(1 "`l1'" 2 "`l2'" )) ylabel(,angle(0)) ///
	plot1opts(lcolor("blue")) plot2opts(lcolor("red"))  censored(single) title(" ")
	graph export "KMTPOS.png", as(png) replace
	graph save Graph "22.gph", replace
	
	stcox i.WHendpos
	local HR1 = 5.54
	local L1 = 1.83
	local U1 = 16.8
	local P1 =  "= 0.002"
	sts graph, by(WHendpos) xlabels() legend(order( - "HR `HR1' (`L1' to `U1'), p `P1'") region(lcolor("0 0 0 %0") fcolor("0 0 0 %0")) pos(5) ring(0) cols(1)) xtitle("Time from surgery (months)") title("") ///
	ytitle("Overall survival") graphregion(fcolor("255 255 255") lcolor("255 255 255")) plotregion(margin(zero)) risktable(,order(1 "`l1'" 2 "`l2'" )) ylabel(,angle(0)) ///
	plot1opts(lcolor("blue")) plot2opts(lcolor("red"))  censored(single) title(" ")
	graph export "KMTEOTOS.png", as(png) replace
	graph save Graph "23.gph", replace
	
	graph combine 11.gph 12.gph 13.gph 21.gph 22.gph 23.gph, cols(3) iscale(0.4) graphregion(margin(zero) fcolor("255 255 255") lcolor("255 255 255") ifcolor("255 255 255") ilcolor("255 255 255")) imargin(zero)
	graph display, xsize(20) ysize(12)
	graph export "Fig4.png", as(png) replace
	
}
if (1 == 1) {
	gen WHserial = .
	replace WHserial = 0 if WHbaselinectDNAT0 == 0 & WHpostopctDNA == 0
	replace WHserial = 1 if WHbaselinectDNAT0 == 1 & WHpostopctDNA == 0
	replace WHserial = 2 if WHbaselinectDNAT0 == 0 & WHpostopctDNA == 1
	replace WHserial = 3 if WHbaselinectDNAT0 == 1 & WHpostopctDNA == 1
	stset WHRFS, failure(WHRFSstatus)
	sts graph, by(WHserial) xlabels() legend(margin(zero) bmargin(zero) order( -  - - " "  - " " 1 "Negative-negative: RFS60 = 1, baseline" ///
	2 "Positive-negative: RFS60 = 0.63 (0.48 to 0.83), p = 0.001" 3 "Negative-positive, RFS60 = 0" 4 "Positive-positive: RFS60 = 0.18 (0.05 to 0.64), p = 0.003" ) textwidth(60) size(2.5) region(margin(zero) lcolor("0 0 0 %0") fcolor("0 0 0 %0")) pos(3) ring(0) cols(1)) xtitle("Time from surgery (months)") title("") ///
	ytitle("Recurrence-free survival") graphregion(fcolor("255 255 255") lcolor("255 255 255")) plotregion(margin(zero)) risktable(,order(1 "Negative-negative" 2 "Positive-negative" 3 "Negative-positive" 4 "Positive-positive" )) ylabel(,angle(0)) ///
	plot1opts(lcolor("blue")) plot2opts(lcolor("green")) plot3opts(lcolor("gold")) plot4opts(lcolor("red"))  censored(single) title(" ")
	graph export "Fig5a.png", as(png) replace
	//graph export "KMTPOS.png", as(png) replace
}
if (1 == 1) {
	su BaselinectDNAMAF, d
		stset WHRFS, failure(WHRFSstatus)
	gen WHQ = .
	replace WHQ = 0 if BaselinectDNAMAF <= .1450085
	replace WHQ = 1 if BaselinectDNAMAF > .1450085 & BaselinectDNAMAF <=  1.038002
	replace WHQ = 2 if BaselinectDNAMAF > 1.038002 & BaselinectDNAMAF <=  7.233039
	replace WHQ = 3 if BaselinectDNAMAF > 7.233039 & BaselinectDNAMAF <=   58.93092
	
	stcox i.WHQ
	local HR1 = 2.59
	local L1 = "0.67"
	local U1 = 10.04
	local P1 =  "0.17"
	
	local HR2 = 1.79
	local L2 = "0.43"
	local U2 = 7.49
	local P2 =  "0.43"
	
	local HR3 = 3.45
	local L3 = "0.91"
	local U3 = 13.06
	local P3 =  "0.069"
	sts graph, by(WHQ) xlabels() legend(margin(zero) bmargin(zero) order( 1 "Q1 " 2 "Q2, HR = `HR1' (`L1' to `U1'), p = `P1'" 3 "Q3, HR = `HR2' (`L2' to `U2'), p = `P2'" 4 "Q4, HR = `HR3' (`L3' to `U3'), p = `P3'" ///
	 )   region( lcolor("0 0 0 %0") fcolor("0 0 0 %0")) pos(4) ring(0) cols(1)) xtitle("Time from surgery (months)") title("") ///
	ytitle("Recurrence-free survival") graphregion(fcolor("255 255 255") lcolor("255 255 255")) plotregion(margin(zero)) risktable(,order(1 "Q1" 2 "Q2" 3 "Q3" 4 "Q4" )) ylabel(,angle(0)) ///
	plot1opts(lcolor("blue")) plot2opts(lcolor("green")) plot3opts(lcolor("gold")) plot4opts(lcolor("red"))  censored(single) title(" ")
	graph export "FigS2.png", as(png) replace

}

if (1 == 1) {
	gen id = _n
	keep if Cohort == 2
	keep JHUID id BaselinectDNAMAF PostNACC*MAF
	foreach var in PostNACC2_ctDNAMAF PostNACC3_ctDNAMAF PostNACC4_ctDNAMAF {
		replace `var' = "." if `var' == "NA"
		destring `var', replace
	}

	rename Baseline  C1
	rename PostNACC2 C2
	rename PostNACC3 C3
	rename PostNACC4 C4
	
	reshape long C, i(id) j(t)
	replace C = 1e-6 if C == 0
	gen CP = C/100
	gen logitCP = log(CP/(1-CP))
	gen lnC = log(C)
	//gen lnT0 = log(T0)
	xtset id t
	mixed lnC t || id: t, robust
	exit
}
if (1 == 1) {
	di "Sank"
	gen WHTP = .
	replace WHTP = 1 if PostopctDNATP == "Positive"
	replace WHTP = 0 if PostopctDNATP == "Negative"
	gen WHTEOT = .
	replace WHTEOT = 1 if EndofalltreatmentctDNAstatu == "Positive"
	
	replace WHTEOT = 0 if EndofalltreatmentctDNAstatu == "Negative"
	
	keep if Adjuvant == "Yes" | Adjuvant == "yes"
	keep WH* Adjuvant
	
	drop if WHTP > 999 | WHTEOT > 999
		
	sort WHTP WHTEOT WHRFSstatus
	gen WHorder0 = _n
	gen WHnorder0 = - WHorder0
	gen WHorder1 = _n
	gen WHnorder1 = - WHorder1
	
	gen WHstate0 = .
	replace WHstate0 = 1 if WHTP == 1
	replace WHstate0 = 0 if WHTP == 0
	gen WHstate1 = WHstate0
	
	sort WHTEOT, stable
	gen WHorder2 = _n
	gen WHnorder2 = - WHorder2
	gen WHstate2 = .
	replace WHstate2 = 1 if WHTEOT == 1
	replace WHstate2 = 0 if WHTEOT == 0
	
	sort WHRFSstatus, stable 
	gen WHorder3 = _n
	gen WHnorder3 = - WHorder3
	gen WHstate3 = .
	replace WHstate3 = 1 if WHRFSstatus == 1
	replace WHstate3 = 0 if WHRFSstatus == 0

	sort WHTP WHTEOT WHRFSstatus
	
	gen WHid = _n
	gen x0 = 0
	gen x1 = 1
	gen x2 = 2
	gen x3 = 3
	
	reshape long WHnorder x WHstate, i(WHid) j(t)
 
	local lcol1 = "blue%20"
	local lcol2 = "red%20"
	local lwidth = 2
	
	drop if x == 0
 
	local qwidth = 0.1
	local qx1 = 1 - `qwidth'
	local qx2 = 1 + `qwidth'
	local qx3 = 2 - `qwidth'
	local qx4 = 2 + `qwidth'
	local qx5 = 3 - `qwidth' 
	local qx6 = 3 + `qwidth'
 
	input ytop yb1 yb2 yb3 ybottom qx
	-0.5 -21.5 -26.5 -25.5 -36.5 0.85
	-0.5 -21.5 -26.5 -25.5 -36.5 1.15
	-0.5 -21.5 -26.5 -25.5 -36.5 1.85
	-0.5 -21.5 -26.5 -25.5 -36.5 2.15
	-0.5 -21.5 -26.5 -25.5 -36.5 2.85
	-0.5 -21.5 -26.5 -25.5 -36.5 3.15
	end
 
	local fill = "%100"
	
	expand 2, generate(gen)
	expand 2, generate(gen2)
	//replace gen = 2 in 121/180
	replace x = x - 0.15 if gen == 1
	replace x = x + 0.15 if gen2 == 1
	sort x
	drop if x < 1  | x > 3
	/*|| line WHnorder x if WHid == 13 & x < 2.1, lcolor(`lcol1') lwidth(`lwidth') ///
	|| line WHnorder x if WHid == 13 & x > 1.9, lcolor(`lcol2') lwidth(`lwidth') ///
	|| line WHnorder x if WHid == 14 & x < 2.1, lcolor(`lcol1') lwidth(`lwidth') ///
	|| line WHnorder x if WHid == 14 & x > 1.9, lcolor(`lcol2') lwidth(`lwidth') ///
	|| line WHnorder x if WHid == 15 & x < 2.1, lcolor(`lcol1') lwidth(`lwidth') ///
	|| line WHnorder x if WHid == 15 & x > 1.9, lcolor(`lcol2') lwidth(`lwidth') ///
	|| line WHnorder x if WHid == 16 & x < 1.1, lcolor(`lcol1') lwidth(`lwidth') ///
	|| line WHnorder x if WHid == 16 & x > 0.1, lcolor(`lcol2') lwidth(`lwidth') ///
	|| line WHnorder x if WHid == 17 & x < 1.1, lcolor(`lcol1') lwidth(`lwidth') ///
	|| line WHnorder x if WHid == 17 & x > 0.1, lcolor(`lcol2') lwidth(`lwidth') ///
	|| line WHnorder x if WHid == 18 & x < 1.1, lcolor(`lcol2') lwidth(`lwidth') ///
	|| line WHnorder x if WHid == 18 & x > 0.1 & x < 2.1, lcolor(`lcol1') lwidth(`lwidth') ///
	|| line WHnorder x if WHid == 18 & x > 1.9, lcolor(`lcol2') lwidth(`lwidth') ///
	|| line WHnorder x if WHid == 19, lcolor(`lcol2') lwidth(`lwidth') ///
	|| line WHnorder x if WHid == 20, lcolor(`lcol2') lwidth(`lwidth') /// */

	/*
	replace WHnorder = -26 if WHid == 28 & x < 1.5
	replace WHnorder = -24 if WHid == 28 & x > 1.5 & x < 2.5
	//replace WHnorder = -20 if WHid == 28 & x > 2.5
	replace WHnorder = -28 if WHid == 26 & x < 1.5
	replace WHnorder = -26 if WHid == 26 & x > 1.5 & x < 2.5
	//replace WHnorder = -26 if WHid == 26 & x > 2.5
*/
	//replace WHnorder = 
	replace WHnorder = 24 if WHnorder == -24 & x > 1.5 & x < 2.5
	replace WHnorder = 25 if WHnorder == -25 & x > 1.5 & x < 2.5
	replace WHnorder = 26 if WHnorder == -26 & x > 1.5 & x < 2.5
	replace WHnorder = -26 if WHnorder == -23 & x > 1.5 & x < 2.5
	replace WHnorder = -25 if WHnorder == -22 & x > 1.5 & x < 2.5
	replace WHnorder = -24 if WHnorder == -21 & x > 1.5 & x < 2.5
	replace WHnorder = -23 if WHnorder == -20 & x > 1.5 & x < 2.5
	replace WHnorder = -20 if WHnorder == 24 & x > 1.5 & x < 2.5
	replace WHnorder = -21 if WHnorder == 25 & x > 1.5 & x < 2.5
	replace WHnorder = -22 if WHnorder == 26 & x > 1.5 & x < 2.5
	replace WHnorder = 26 if WHnorder == -26 & x > 2.5
	replace WHnorder = -26 if WHnorder == -25 & x > 2.5
	replace WHnorder = -25 if WHnorder == -24 & x > 2.5
	replace WHnorder = -24 if WHnorder == -23 & x > 2.5
	replace WHnorder = -23 if WHnorder == -22 & x > 2.5
	replace WHnorder = -22 if WHnorder == 26 & x > 2.5
	
	tw line WHnorder x if WHid == 1, lcolor(`lcol1') lwidth(`lwidth') ///
	|| line WHnorder x if WHid == 2, lcolor(`lcol1') lwidth(`lwidth') ///
	|| line WHnorder x if WHid == 3, lcolor(`lcol1') lwidth(`lwidth') ///
	|| line WHnorder x if WHid == 4, lcolor(`lcol1') lwidth(`lwidth') ///
	|| line WHnorder x if WHid == 5, lcolor(`lcol1') lwidth(`lwidth') ///
	|| line WHnorder x if WHid == 6, lcolor(`lcol1') lwidth(`lwidth') ///
	|| line WHnorder x if WHid == 7, lcolor(`lcol1') lwidth(`lwidth') ///
	|| line WHnorder x if WHid == 8, lcolor(`lcol1') lwidth(`lwidth') ///
	|| line WHnorder x if WHid == 9, lcolor(`lcol1') lwidth(`lwidth') ///
	|| line WHnorder x if WHid == 10, lcolor(`lcol1') lwidth(`lwidth') ///
	|| line WHnorder x if WHid == 11, lcolor(`lcol1') lwidth(`lwidth') ///
	|| line WHnorder x if WHid == 12, lcolor(`lcol1') lwidth(`lwidth') ///
	|| line WHnorder x if WHid == 13, lcolor(`lcol1') lwidth(`lwidth') ///
	|| line WHnorder x if WHid == 14, lcolor(`lcol1') lwidth(`lwidth') ///
	|| line WHnorder x if WHid == 15, lcolor(`lcol1') lwidth(`lwidth') ///
	|| line WHnorder x if WHid == 16, lcolor(`lcol1') lwidth(`lwidth') ///
	|| line WHnorder x if WHid == 17, lcolor(`lcol1') lwidth(`lwidth') ///
	|| line WHnorder x if WHid == 18, lcolor(`lcol1') lwidth(`lwidth') ///
	|| line WHnorder x if WHid == 19, lcolor(`lcol1') lwidth(`lwidth') ///
	|| line WHnorder x if WHid == 20 & x < 2.1, lcolor(`lcol1') lwidth(`lwidth') ///
	|| line WHnorder x if WHid == 20 & x > 2.1, lcolor(`lcol2') lwidth(`lwidth') ///
	|| line WHnorder x if WHid == 21 & x < 2.1, lcolor(`lcol1') lwidth(`lwidth') ///
	|| line WHnorder x if WHid == 21 & x > 2.1, lcolor(`lcol2') lwidth(`lwidth') ///
	|| line WHnorder x if WHid == 22 & x < 2.1, lcolor(`lcol1') lwidth(`lwidth') ///
	|| line WHnorder x if WHid == 22 & x > 2.1, lcolor(`lcol2') lwidth(`lwidth') ///
	|| line WHnorder x if WHid == 23 & x < 2.1, lcolor(`lcol1') lwidth(`lwidth') ///
	|| line WHnorder x if WHid == 23 & x > 2.1, lcolor(`lcol2') lwidth(`lwidth') ///
	|| line WHnorder x if WHid == 24, lcolor(`lcol2') lwidth(`lwidth') ///
	|| line WHnorder x if WHid == 25, lcolor(`lcol2') lwidth(`lwidth') ///
	|| line WHnorder x if WHid == 26, lcolor(`lcol1') lwidth(`lwidth') ///
	|| line WHnorder x if WHid == 27, lcolor(`lcol1') lwidth(`lwidth') ///
	|| line WHnorder x if WHid == 28 & x < 2.1, lcolor(`lcol1') lwidth(`lwidth') ///
	|| line WHnorder x if WHid == 28 & x > 2.1, lcolor(`lcol2') lwidth(`lwidth') ///
	|| line WHnorder x if WHid == 29, lcolor(`lcol2') lwidth(`lwidth') ///
	|| line WHnorder x if WHid == 30, lcolor(`lcol2') lwidth(`lwidth') ///
	|| line WHnorder x if WHid == 31, lcolor(`lcol2') lwidth(`lwidth') ///
	|| line WHnorder x if WHid == 32, lcolor(`lcol2') lwidth(`lwidth') ///
	|| line WHnorder x if WHid == 33, lcolor(`lcol2') lwidth(`lwidth') ///
	|| line WHnorder x if WHid == 34, lcolor(`lcol2') lwidth(`lwidth') ///
	|| line WHnorder x if WHid == 35, lcolor(`lcol2') lwidth(`lwidth') ///
	|| line WHnorder x if WHid == 36, lcolor(`lcol2') lwidth(`lwidth') ///
	|| scatter WHnorder x if WHstate == 0 & (x == 1 | x == 2 | x == 3), mcolor("blue") ///
	|| scatter WHnorder x if WHstate == 1 & (x == 1 | x == 2 | x == 3), mcolor("red") ///
	|| rarea ytop yb1 qx if qx > 2.5, fcolor("255 255 255 `fill'") lcolor("black") ///
	|| rarea ytop yb2 qx if qx > 1.5 & qx < 2.5, fcolor("255 255 255 `fill'") lcolor("black") ///
	|| rarea ytop yb3 qx if qx < 1.5, fcolor("255 255 255 `fill'") lcolor("black") ///
	|| rarea yb1 ybottom qx if qx > 2.5, fcolor("255 255 255 `fill'") lcolor("black") ///
	|| rarea yb2 ybottom qx if qx > 1.5 & qx < 2.5, fcolor("255 255 255 `fill'") lcolor("black") ///
	|| rarea yb3 ybottom qx if qx < 1.5, fcolor("255 255 255 `fill'") lcolor("black") ///
	legend(off) ylabels(-1 " ", noticks nogmax) xlabels(1 "T{sub:P}" 2 "T{sub:EOT}" 3 "Recurrence") ytitle("") yscale(lstyle(none)) xscale(lstyle(none)) ///
	text(-13 1 "ctDNA−" "n = 25" "(69%)") text(-31 1 "ctDNA+" "n = 11" "(31%)") ///
	text(-12 1.15 " n = 23 (92%)", justification(left) placement(e)) ///
	text(-24.5 1.15 " n = 2 (8%)", justification(left) placement(e)) ///
	text(-27 1.15 " n = 3 (27%)", justification(left) placement(e)) ///
	text(-32.5 1.15 " n = 8 (73%)", justification(left) placement(e)) ///
	text(-13.5 2 "ctDNA−" "n = 26" "(72%)") text(-31.5 2 "ctDNA+" "n = 10" "(28%)") ///
	text(-11 2.15 " n = 21 (81%)", justification(left) placement(e)) ///
	text(-24 2.15 " n = 5 (19%)", justification(left) placement(e)) ///
	text(-31.5 2.15 " n = 10 (100%)", justification(left) placement(e)) ///
	text(-11 3 "No" "n = 21" "(58%)") text(-29 3 "Yes" "n = 15" "(42%)") ///
	plotregion(margin(zero)) graphregion(fcolor("255 255 255"))
 graph export "Sankey.png", as(png) replace 
 
 
 
 
 
 
 
 
	exit
	tw scatter WHnorder0 x0 if WHTP == 0, mcolor("blue") ///
	|| scatter WHnorder0 x0 if WHTP == 1, mcolor("red") ///
	|| scatter WHnorder1 x1 if WHTP == 0, mcolor("blue") ///
	|| scatter WHnorder1 x1 if WHTP == 1, mcolor("red") ///
	|| scatter WHnorder2 x2 if WHTEOT == 0, mcolor("blue") ///
	|| scatter WHnorder2 x2 if WHTEOT == 1, mcolor("red") ///
	|| scatter WHnorder3 x3 if WHRFSstatus == 0, mcolor("blue") ///
	|| scatter WHnorder3 x3 if WHRFSstatus == 1, mcolor("red") ///
	, legend(off)
	exit
}
if (1 == 1) {
	di "SWIMMER TEST"
	gen WHCohort = Cohort
	gen WHT0 = .
	replace WHT0 = 1 if BaselinectDNAT0 == "Positive"
	replace WHT0 = 0 if BaselinectDNAT0 == "Negative"
	gen WHTC2 = .
	replace WHTC2 = 1 if PostNACC2_ctDNATC2 == "Positive"
	replace WHTC2 = 0 if PostNACC2_ctDNATC2 == "Negative"
	gen WHTC3 = .
	replace WHTC3 = 1 if PostNACC3_ctDNATC3 == "Positive"
	replace WHTC3 = 0 if PostNACC3_ctDNATC3 == "Negative"
	gen WHTC4 = .
	replace WHTC4 = 1 if PostNACC4_ctDNATC4 == "Positive"
	replace WHTC4 = 0 if PostNACC4_ctDNATC4 == "Negative"
	gen WHTP = .
	replace WHTP = 1 if PostopctDNATP == "Positive"
	replace WHTP = 0 if PostopctDNATP == "Negative"
	gen WHTEOT = .
	replace WHTEOT = 1 if EndofalltreatmentctDNAstatu == "Positive"
	replace WHTEOT = 0 if EndofalltreatmentctDNAstatu == "Negative"
	gen WHTfu = .
	replace WHTfu = 1 if ctDNAduringfollowup == "Positive"
	replace WHTfu = 0 if ctDNAduringfollowup == "Negative"
	gen WHorder = 0
	replace WHorder = WHorder + 1 if WHTfu == 1
	replace WHorder = WHorder + 2 if WHTEOT == 1
	replace WHorder = WHorder + 4 if WHTP == 1
	replace WHorder = WHorder + 8 if WHTC4 == 1
	replace WHorder = WHorder + 16 if WHTC3 == 1
	replace WHorder = WHorder + 32 if WHTC2 == 1
	replace WHorder = WHorder + 64 if WHT0 == 1
	keep WH*
	gsort -WHCohort -WHorder -WHOS
	gen WHid = _n
	gen WHnegid = -WHid
	gen WHx1 = 1 if WHT0 < 99999
	gen WHx2 = 2 if WHTC2 < 99999
	gen WHx3 = 3 if WHTC3 < 99999
	gen WHx4 = 4 if WHTC4 < 99999
	gen WHx5 = 5 if WHTP < 99999
	gen WHx6 = 6 if WHTEOT < 99999
	gen WHx7 = 7 if WHTfu < 99999
	
	local target = 2
	if (1 == 0) {
		tw scatter WHnegid WHx1 if WHCohort == `target' & WHT0 == 0, mcolor("green") ///
		|| scatter WHnegid WHx2 if WHCohort == `target' & WHTC2 == 0, mcolor("green") ///
		|| scatter WHnegid WHx3 if WHCohort == `target' & WHTC3 == 0, mcolor("green") ///
		|| scatter WHnegid WHx4 if WHCohort == `target' & WHTC4 == 0, mcolor("green") ///
		|| scatter WHnegid WHx5 if WHCohort == `target' & WHTP == 0, mcolor("green") ///
		|| scatter WHnegid WHx6 if WHCohort == `target' & WHTEOT == 0, mcolor("green") ///
		|| scatter WHnegid WHx7 if WHCohort == `target' & WHTfu == 0, mcolor("green") ///
		|| scatter WHnegid WHx1 if WHCohort == `target' & WHT0 == 1, mcolor("red") ///
		|| scatter WHnegid WHx2 if WHCohort == `target' & WHTC2 == 1, mcolor("red") ///
		|| scatter WHnegid WHx3 if WHCohort == `target' & WHTC3 == 1, mcolor("red") ///
		|| scatter WHnegid WHx4 if WHCohort == `target' & WHTC4 == 1, mcolor("red") ///
		|| scatter WHnegid WHx5 if WHCohort == `target' & WHTP == 1, mcolor("red") ///
		|| scatter WHnegid WHx6 if WHCohort == `target' & WHTEOT == 1, mcolor("red") ///
		|| scatter WHnegid WHx7 if WHCohort == `target' & WHTfu == 1, mcolor("red") ///
		, legend(order(10 "ctDNA-Positive" 1 "ctDNA-Negative") region( lcolor("0 0 0 %0") fcolor("0 0 0 %0")) ) ///
		ylabels(-1  " " -2  " " -3  " " -4  " " -5  " " -6  " " -7  " " -8  " " -9  " " -10 " " ///
				-11 " " -12 " " -13 " " -14 " " -15 " " -16 " " -17 " " -18 " " -19 " " -20 " " ///
				-21 " " -22 " " -23 " ") xlabels(1 "T{sub:0}" 2 "T{sub:C2}" 3 "T{sub:C3}" 4 "T{sub:C4}" 5 "T{sub:P}" 6 "T{sub:EOT}" 7 "T{sub:follow-up}") ///
		ytitle("Patients (cohort 2)") xtitle("Time points") graphregion(margin(zero) fcolor("255 255 255") lcolor("255 255 255")) fxsize(100)
		//graph display, xsize(1) ysize(2)
		graph save Graph "t2.gph", replace	
		tw bar WHOS WHnegid if WHCohort == 2, hor lcolor("0 0 0 %0") fcolor("blue%33") ///
		|| scatter WHnegid WHOS if WHCohort == 2 & WHOSstatus == 1, mcolor("red") ms(X) msize(2.5) ///
		|| scatter WHnegid WHRFS if WHCohort == 2 & WHRFSstatus == 1, mcolor("red") ms(Oh) ///
		|| scatter WHnegid WHOS if WHCohort == 2 & WHOSstatus == 0, mcolor("green") ms(arrowf) msangle(90) msize(2.5) ///
		legend(order(4 "Alive" 3 "Recurrence" 2 "Deceased") region( lcolor("0 0 0 %0") fcolor("0 0 0 %0")) cols(3)) xtitle("Months since study entry") ///
		ylabels(-1  " " -2  " " -3  " " -4  " " -5  " " -6  " " -7  " " -8  " " -9  " " -10 " " ///
				-11 " " -12 " " -13 " " -14 " " -15 " " -16 " " -17 " " -18 " " -19 " " -20 " " ///
				-21 " " -22 " " -23 " ") ytitle("") plotregion(margin(zero)) graphregion(margin(zero) fcolor("255 255 255 %0") lcolor("255 255 255 %0")) fxsize(200)
		graph save Graph "s2.gph", replace	

			graph combine t2.gph s2.gph, iscale(0.6)  plotregion(margin(zero)) graphregion( fcolor("255 255 255") lcolor("255 255 255") ifcolor("255 255 255") ilcolor("255 255 255")) //imargin(zero)
	graph export "swim2.png", as(png) replace

		//graph combine t2.gph s2.gph, iscale(0.6)  plotregion( graphregion(margin(zero) fcolor("255 255 255") lcolor("255 255 255") ifcolor("255 255 255") ilcolor("255 255 255")) //imargin(zero)
		exit
	}
	
	
	
	
	local target = 1
	drop WHx2 WHx3 WHx4 WHx5 WHx6 WHx7
	gen WHx2 = 2 if WHTP < 99999
	gen WHx3 = 3 if WHTEOT < 99999
	gen WHx4 = 4 if WHTfu < 99999
	tw scatter WHnegid WHx1 if WHCohort == `target' & WHT0 == 0, mcolor("green") ///
	|| scatter WHnegid WHx2 if WHCohort == `target' & WHTP == 0, mcolor("green") ///
	|| scatter WHnegid WHx3 if WHCohort == `target' & WHTEOT == 0, mcolor("green") ///
	|| scatter WHnegid WHx4 if WHCohort == `target' & WHTfu == 0, mcolor("green") ///
	|| scatter WHnegid WHx1 if WHCohort == `target' & WHT0 == 1, mcolor("red") ///
	|| scatter WHnegid WHx2 if WHCohort == `target' & WHTP == 1, mcolor("red") ///
	|| scatter WHnegid WHx3 if WHCohort == `target' & WHTEOT == 1, mcolor("red") ///
	|| scatter WHnegid WHx4 if WHCohort == `target' & WHTfu == 1, mcolor("red") ///
	legend(order(6 "ctDNA-Positive" 1 "ctDNA-Negative") region( lcolor("0 0 0 %0") fcolor("0 0 0 %0")) ) ///
	ylabels(-24 " " -25 " " -26 " " -27 " " -28 " " -29 " " -30 " " -31 " " -32 " " -33 " " ///
	        -34 " " -35 " " -36 " " -37 " " -38 " " -39 " " -40 " " -41 " " -42 " " -43 " " ///
			-44 " " -45 " " -46 " " -47 " " -48 " " -49 " " -50 " " -51 " " -52 " " -53 " " ///
	        -54 " " ) /// 
	xlabels(1 "T{sub:0}" 2 "T{sub:P}" 3  "T{sub:EOT}" 4 "T{sub:follow-up}") ///
	ytitle("Patients (cohort 1)") xtitle("Time points")  graphregion(margin(zero) fcolor("255 255 255") lcolor("255 255 255")) fxsize(100)
	//graph display, xsize(1) ysize(2) 
	graph save Graph "t1.gph", replace
	 
	tw bar WHOS WHnegid if WHCohort == 1, hor lcolor("0 0 0 %0") fcolor("blue%33") ///
	|| scatter WHnegid WHOS if WHCohort == 1 & WHOSstatus == 1, mcolor("red") ms(X) msize(2.5) ///
	|| scatter WHnegid WHRFS if WHCohort == 1 & WHRFSstatus == 1, mcolor("red") ms(Oh) ///
	|| scatter WHnegid WHOS if WHCohort == 1 & WHOSstatus == 0, mcolor("green") ms(arrowf) msangle(90) msize(2.5) ///
	legend(order(4 "Alive" 3 "Recurrence" 2 "Deceased") region( lcolor("0 0 0 %0") fcolor("0 0 0 %0")) cols(3)) xtitle("Months since study entry") ///
	ylabels(-24 " " -25 " " -26 " " -27 " " -28 " " -29 " " -30 " " -31 " " -32 " " -33 " " ///
	        -34 " " -35 " " -36 " " -37 " " -38 " " -39 " " -40 " " -41 " " -42 " " -43 " " ///
			-44 " " -45 " " -46 " " -47 " " -48 " " -49 " " -50 " " -51 " " -52 " " -53 " " ///
	        -54 " " ) /// 
	ytitle("") plotregion(margin(zero)) graphregion(margin(zero) fcolor("255 255 255 %0")   lcolor("255 255 255 %0")) fxsize(200)
	graph save Graph "s1.gph", replace	

	graph combine t1.gph s1.gph, iscale(0.6)  plotregion(margin(zero)) graphregion( fcolor("255 255 255") lcolor("255 255 255") ifcolor("255 255 255") ilcolor("255 255 255")) //imargin(zero)
	graph export "swim1.png", as(png) replace
}
