/* Identify Multum Lexicon drug codes from RxNorm */
/* By: Steven M Smith, Univ of Florida 						*/
/* Last Updated: June 12, 2020										*/

/* Skip to creation of the medlist if you already have the RxNorm RXNCONSO
tables loaded in SAS, . Otherwise, download RxNorm files from UMLS here:
https://www.nlm.nih.gov/research/umls/rxnorm/docs/rxnormfiles.html and
customize these macro variables: */

/* Full path to the RXNCONSO.RRF file - OPTIONAL (skip if already have
RXNCONSO table loaded) */
%let RxNorm_path = "E:\DATA\RXNORM\RxNorm_full_20200406\rrf\RXNCONSO.RRF" ;

/* Where to store the SAS dataset - REQUIRED
	If dataset is already stored locally, use this to identify its location */
%let RxNorm_DSN = WORK.rxnconso_20200406 ;

/* Where to store the final drug code dataset */
%let drug_code_dsn = WORK.mmsl_codes ;

/* load RxNorm data */
data &RxNorm_DSN ;
	%let _EFIERR_ = 0;
	infile &RxNorm_path delimiter='|' MISSOVER DSD lrecl=32767;
	informat RXCUI $8. LAT $3. TS $1. LUI $8. STT $3. SUI $8. ISPREF $1. RXAUI $8. SAUI $50. SCUI $50. SDUI $50. SAB $20.
		TTY $20. CODE $50. STR $3000. SRL $10. SUPPRESS $1. CVF $4. ;
	format RXCUI $8. LAT $3. TS $1. LUI $8. STT $3. SUI $8. ISPREF $1. RXAUI $8. SAUI $50. SCUI $50. SDUI $50. SAB $20.
		TTY $20. CODE $50. STR $3000. SRL $10. SUPPRESS $1. CVF $4. ;
	input RXCUI $ LAT $ TS $ LUI $ STT $ SUI $ ISPREF $ RXAUI $ SAUI $ SCUI $ SDUI $ SAB $ TTY $ CODE $ STR $ SRL $
		SUPPRESS $ CVF $;
	if _ERROR_ then call symputx('_EFIERR_',1);
run;


/* list of drugs (and any other indicators needed, e.g., drug class) to search
for in the RxNorm file above. medname must be the generic drug name */
/* This example is for antihypertensive drugs */
data medlist;
	length medname sd_class $40 ;
	input medname sd_class $&;
	medname = upcase (medname);
	sd_class = upcase(sd_class);
	datalines;
losartan ARB
olmesartan ARB
telmisartan ARB
telmisartin ARB
candesartan ARB
eprosartan ARB
azilsartan ARB
irbesartan ARB
valsartan ARB
benazepril ACE
bzp ACE
captopril ACE
cilazapril ACE
enalapril ACE
enalaprilat ACE
fosinopril ACE
FNP ACE
lisinopril ACE
moexipril ACE
moexiprilat ACE
perindopril ACE
perindoprilat ACE
quinapril ACE
quinaprilat ACE
ramipril ACE
ramiprilat ACE
trandolapril ACE
trandolaprilat ACE
aliskiren DRI
acebutolol BB
atenolol BB
nadolol BB
oxprenolol BB
betaxolol BB
bisoprolol BB
carteolol BB
timolol BB
bucindolol BB
esmolol BB
labetalol BB
carvedilol BB
metoprolol BB
propranolol BB
nebivolol BB
penbutolol BB
pindolol BB
sotalol BB
metipranolol BB
verapamil CCB
diltiazem CCB
nifedipine CCB
nicardipine CCB
felodipine CCB
benidipine CCB
isradipine CCB
nilvadipine CCB
nimodipine CCB
nisoldipine CCB
nitrendipine CCB
amlodipine CCB
azelnidipine CCB
clevidipine CCB
efonidipine CCB
lacidipine CCB
lercanidipine CCB
manidipine CCB
levamlodipine CCB
cilnidipine CCB
bendroflumethiazide thiazide
chlortalidone thiazide
chlorthalidone thiazide
hydrochlorothiazide thiazide
HCTZ thiazide
chlorothiazide thiazide
methyclothiazide thiazide
polythiazide thiazide
buthiazide thiazide
cyclothiazide thiazide
benzothiazide thiazide
xipamide thiazide
flumethiazide thiazide
clopamide thiazide
althiazide thiazide
indapamide thiazide
metolazone thiazide
trichlormethiazide thiazide
cyclopenthiazide thiazide
amiloride k_sparing
eplerenone aldo_antag
spironolactone aldo_antag
triamterene k_sparing
bumetanide loop
torsemide loop
furosemide loop
ethacrynic loop
ethacrynate loop
edecrin loop
prazosin alpha_blocker
terazosin alpha_blocker
doxazosin alpha_blocker
clonidine centrally_acting
methyldopa centrally_acting
methyldopate centrally_acting
guanabenz centrally_acting
guanfacine centrally_acting
guanadrel centrally_acting
guanethidine centrally_acting
moxonidine centrally_acting
rilmenidine centrally_acting
phenoxybenzamine alpha_blocker
phentolamine alpha_blocker
reserpine other
deserpidine other
rauwolfia other
serpentina other
minoxidil vasodilator
hydralazine vasodilator
nitroprusside vasodilator
hydroflumethiazide thiazide
;
run;

/* Query the medlist against the RxNorm file and pull out the drug code
information. Add any other indicators needed from medlist as
b.variable_name */
proc sql;
	create table &drug_code_dsn as
	select a.rxcui, a.str, a.code, b.medname, b.sd_class as class
	from &RxNorm_DSN a left join medlist b
	on upcase(a.str) contains trim(b.medname)
		where a.TTY='GN' and SAB="MMSL" and b.medname is not missing;
quit;

/* Sort however you like, or don't sort at all */
proc sort; by class medname; run;

/* The above file may require some manual curation because the drug codes are
selected on a string search of the medname. So for example, if you want oral
timolol, but not opthalmic timolol, you would need to remove those */


/* Or, alternatively, for antihypertensives, compare against my already curated
RxCUI lists and remove unwanted items that way, as below */
proc sql;
	create table antihtn_drug_codes as
	select a.code as drugid, a.rxcui, a.str, b.medname1, b.medname2, b.medname3, b.class1, b.class2, b.class3, b.single_medname_var,
		b.single_class_var, b.n_drugs, b.fdc
	from &drug_code_dsn a left join antihtn_rxcui_classes b
	on a.rxcui=b.rxcui;
quit;

/* toss drugs that didn't have a code */
data antihtn_drug_codes; set antihtn_drug_codes(where=(single_medname_var ne "")); run;

/* get rid of duplicates */
proc sort data=antihtn_drug_codes nodupkey; by _ALL_; run;

/* final save */
proc sort data=antihtn_drug_codes out=antihtn_drugids_mmsl ; by fdc single_class_var single_medname_var; run;


/** End Creation of drug code list **/
