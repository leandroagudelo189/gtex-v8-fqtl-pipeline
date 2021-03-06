## Run FQTL

CHR := $(shell seq 1 22)

all: $(foreach chr, $(CHR), $(foreach tt, fqtl null, jobs/step5/run_$(chr)_$(tt).txt.gz)) #  jobs/step5/nonneg-run_$(chr)_$(tt).txt.gz

long: $(foreach chr, $(CHR), $(foreach tt, fqtl null, jobs/step5/run_$(chr)_$(tt)-long.txt.gz jobs/step5/nonneg-run_$(chr)_$(tt)-long.txt.gz))

combine:
	Rscript --vanilla ./make.combine_fqtl.R

jobs/step5/run_%-long.txt.gz: jobs/step5/run_%.txt.gz
	@zcat $< | awk 'system("! [ -f " $$(NF - 1) ".combined.gz ]") == 0' | gzip > $@
	[ $$(zcat $@ | wc -l) -eq 0 ] || qsub -P compbio_lab -o /dev/null -binding linear:1 -cwd -V -l h_vmem=4g -l h_rt=16:00:00 -b y -j y -N long_$* -t 1-$$(zcat $@ | wc -l) ./run_jobs.sh $@

jobs/step5/run_%_fqtl.txt.gz: 
	@[ -d $(dir $@) ] || mkdir -p $(dir $@)
	@ls -1 processed/combined/chr$*/*.txt.gz | sed 's/.txt.gz//' | awk -vOFS=' ' -F'/' '{ print "./make.fqtl.R" OFS ($$0 ".txt.gz") OFS ("geno/" $$3) OFS ("fqtl/obs/" $$3 "/" $$4) OFS "FALSE" }' | gzip > $@
	qsub -P compbio_lab -o /dev/null -binding linear:1 -cwd -V -l h_vmem=2g -l h_rt=4:00:00 -b y -j y -N fqtl_$* -t 1-$$(zcat $@ | wc -l) ./run_jobs.sh $@

jobs/step5/run_%_null.txt.gz: 
	@[ -d $(dir $@) ] || mkdir -p $(dir $@)
	@ls -1 processed/combined/chr$*/*.txt.gz | sed 's/.txt.gz//' | awk -vOFS=' ' -F'/' '{ print "./make.fqtl.R" OFS ($$0 ".txt.gz") OFS ("geno/" $$3) OFS ("fqtl/null/" $$3 "/" $$4) OFS "TRUE" }' | gzip > $@
	qsub -P compbio_lab -o /dev/null -binding linear:1 -cwd -V -l h_vmem=2g -l h_rt=4:00:00 -b y -j y -N null_$* -t 1-$$(zcat $@ | wc -l) ./run_jobs.sh $@


# jobs/step5/nonneg-run_%_fqtl.txt.gz: 
# 	@[ -d $(dir $@) ] || mkdir -p $(dir $@)
# 	@ls -1 processed/combined/chr$*/*.txt.gz | sed 's/.txt.gz//' | awk -vOFS=' ' -F'/' '{ print "./make.fqtl.R" OFS ($$0 ".txt.gz") OFS ("geno/" $$3) OFS ("result/nonneg_fqtl_obs/" $$3 "/" $$4) OFS "FALSE" OFS "TRUE" }' | gzip > $@
# 	qsub -P compbio_lab -o /dev/null -binding linear:1 -cwd -V -l h_vmem=2g -l h_rt=4:00:00 -b y -j y -N fqtl_$* -t 1-$$(zcat $@ | wc -l) ./run_jobs.sh $@

# jobs/step5/nonneg-run_%_null.txt.gz: 
# 	@[ -d $(dir $@) ] || mkdir -p $(dir $@)
# 	@ls -1 processed/combined/chr$*/*.txt.gz | sed 's/.txt.gz//' | awk -vOFS=' ' -F'/' '{ print "./make.fqtl.R" OFS ($$0 ".txt.gz") OFS ("geno/" $$3) OFS ("result/nonneg_fqtl_null/" $$3 "/" $$4) OFS "TRUE" OFS "TRUE" }' | gzip > $@
# 	qsub -P compbio_lab -o /dev/null -binding linear:1 -cwd -V -l h_vmem=2g -l h_rt=4:00:00 -b y -j y -N null_$* -t 1-$$(zcat $@ | wc -l) ./run_jobs.sh $@

