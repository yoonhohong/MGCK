
setwd("/Users/yoonhohong/GitHub/MGCK")

library(ggplot2)
library(RColorBrewer)

dem = read.csv("MGCK_demographics_201611.csv", na.strings = c(""))

# demographics 

## a total number of patients enrolled 

## number of patients across centers 
sort(table(dem$hospital), decreasing=T) 
## make a table


## number of enrolled patients across centers
dem$hospital = factor(dem$hospital, levels = 
                        names(sort(table(dem$hospital), decreasing=T))) 


## plot: number of enrolled patients across centers

p = ggplot(dem, aes(x = hospital, fill=gender)) 
p + geom_bar(position="dodge") + 
  ggtitle("Number of enrolled patients across centers") +
  xlab("Hospital") + ylab("Number of patients") + 
  theme_light()

## age distribution 
dem$date_birth = as.Date(dem$date_birth, format = "%Y-%m-%d")
dem$age = round(as.numeric(difftime(Sys.time(), dem$date_birth, units = "weeks")/52))
cutpoints = unique(c(min(dem$age), 20, 30, 40, 50, 60, 70, 80, max(dem$age)))
dem$age_group = cut(dem$age, breaks = cutpoints, 
                    include.lowest = TRUE, right = F)

## plot: age distribution
p1 = ggplot(dem, aes(x=age_group, fill=gender))
p1 + geom_bar(position = "dodge") + 
  ggtitle("Age distribution") + 
  xlab("Age") + ylab("Number of patients") + theme_light()

# diagnosis 

dx = read.csv("MGCK_diagnosis_201611.csv", na.strings = c(""))

## antibodies 
### AChRc 

dx$achrc_ab_dx = ifelse(is.na(dx$achrc_ab_dx), 4, dx$achrc_ab_dx)
dx$achrc_ab_dx = factor(dx$achrc_ab_dx, labels  = 
                          c("negative","borderline","positive", "na")) # 1=negative, 2=borderline, 3=positive, 4=na

pielbls = function(x){ # x should be a table
  lbl = names(x)
  pct = round(x/sum(x)*100)
  lbl = paste(lbl, pct)
  lbl = paste(lbl, "%", sep="")
  return(lbl)
}

sl_achrc = sort(table(dx$achrc_ab_dx), decreasing = T)

## pichart: AChR-Ab
dev.off()
pie(sl_achrc,labels = pielbls(sl_achrc), 
    col=brewer.pal(length(sl_achrc), "Dark2"),
    main=sprintf("AChR-Ab (n=%d)", sum(sl_achrc)))

# histogram: AChR-Ab titer 
p2 = ggplot(dx, aes(x=achrc_ab_titer_dx, y=..count..)) # early vs. late-onset? 
p2 + geom_histogram(fill="midnightblue", col="white") +  
  ggtitle(sprintf("AChR-Ab titers (n=%d)", length(which(!is.na(dx$achrc_ab_titer_dx))))) + 
  xlab("AChR-Ab titer (nmol/L)") +
  ylab("Count") + 
  theme_light()

# MuSK-Ab
# 1=negative, 2=borderline, 3=positive, 4-6=na 
# table 
dx$musk_ab_dx = ifelse(dx$musk_ab_dx %in% c(4,5,6,NA), NA, dx$musk_ab_dx)
dx$musk_ab_dx = factor(dx$musk_ab_dx, levels=c(1:3), labels=c("negative", "borderline", "positive"))
sl_musk = table(dx$musk_ab_dx)
pie(sl_musk, labels = pielbls(sl_musk), 
    main = sprintf("MuSK-Ab (n=%d)", sum(sl_musk)), 
    col=brewer.pal(length(sl_musk), "Dark2"))

# Thymus: chest CT 
levels(dx$thymus_ct) = list(normal = c(1,"atrophy(involution)","normal"), 
                            hyperplasia = c(2,"hyperplasia"),
                            thymoma = c(3,4,"thymoma", "thymic carcinoma"),
                            others = c(5, "others")
)

sl_thymusCT = sort(table(dx$thymus_ct), decreasing = T)

# thymus: final 
dx$thymus_dx = ifelse(dx$thymus_dx %in% c(5,6,7), 5, dx$thymus_dx)
dx$thymus_dx = factor(dx$thymus_dx)
levels(dx$thymus_dx) = list(normal = 1,
                            hyperplasia = 2,
                            thymoma = c(3,4),
                            others = 5)
sl_thymusDX = sort(table(dx$thymus_dx), decreasing = T)

par(mfrow=c(1,2))

pie(sl_thymusCT, labels = pielbls(sl_thymusCT), 
    main = sprintf("Thymus: CT (n=%d)", sum(sl_thymusCT)),
    col = brewer.pal(length(sl_thymusCT), "Dark2"))

pie(sl_thymusDX, labels = pielbls(sl_thymusDX), 
    main = sprintf("Thymus pathology (n=%d)", sum(sl_thymusDX)),
    col = brewer.pal(length(sl_thymusDX), "Dark2"))


# thymoma staging 
levels(dx$staging_thymoma) = list(I = c("I"), 
                                  IIa = c("IIa", "II_a"),
                                  IIb = c("IIb", "II_b"),
                                  III = c("III"),
                                  IVa = c("IVa", "IV_a"),
                                  IVb = c("IVb", "IV_b"))

sl_thymomaST = table(dx$staging_thymoma)

pie(sl_thymomaST, labels = pielbls(sl_thymomaST), 
    col = brewer.pal(length(sl_thymomaST), "Dark2"), 
    main=sprintf("Thymoma staging (n=%d)", sum(sl_thymomaST)))


# WHO classification

sl_thymomaWHO = table(dx$who_thymoma)

pie(sl_thymomaWHO, labels=pielbls(sl_thymomaWHO), 
    col=brewer.pal(length(sl_thymomaWHO), "Dark2"), 
    main=sprintf("Thymoma WHO classification (n=%d)", sum(sl_thymomaWHO)))

# course initial 

ci = read.csv("MGCK_course_initial_201611.csv", na.strings = c(""))
ci$type_onset = factor(ci$type_onset, levels=c(1,2), labels=c("ocular", "generalized"))
ci$type_presentation = factor(ci$type_presentation, levels=c(1,2), labels=c("ocular", "generalized"))


sl_onset = table(ci$type_onset)
sl_presentation = table(ci$type_presentation)

pie(sl_onset, labels=pielbls(sl_onset), col=brewer.pal(length(sl_onset), "Dark2"), 
    main=sprintf("Onset (n=%d)", sum(sl_onset)))
pie(sl_presentation, labels=pielbls(sl_presentation), col=brewer.pal(length(sl_presentation), "Dark2"), 
    main=sprintf("Presentation (n=%d)", sum(sl_presentation)))

# mgfa_entry
# mgfa_firstvisit

.pardefault = par()
par(.pardefault)

levels(ci$mgfa_entry) = list(I = "I",
                             II = c("IIa", "IIb"),
                             III = c("IIIa", "IIIb"),
                             IV = c("IVa", "IVb"),
                             V = "V")
levels(ci$mgfa_firstvisit) = list(CSR = "CSR",
                                  PR = "PR",
                                  MM = "MM",
                                  I = "I",
                                  II = c("IIa", "IIb"),
                                  III = c("IIIa", "IIIb"),
                                  IV = c("IVa", "IVb"),
                                  V = "V")

p = ggplot(ci, aes(x=factor(mgfa_entry), fill=factor(mgfa_firstvisit)))
p + geom_bar(aes(y=(..count..)/sum(..count..)), stat = "count") + 
  scale_y_continuous(labels = scales::percent) +
  labs(y = "Percent", fill="MGFA class or PIS at enrollment") + 
  ggtitle(sprintf("MGFA class at entry & enrollment (n=%d)", sum(table(ci$mgfa_entry)))) + 
  xlab("MGFA class at entry") + theme_light() + theme(legend.position = "bottom") +
  coord_flip()

ci$date_entry = as.Date(ci$date_entry, format="%Y-%m-%d")
ci$date_dx = as.Date(ci$date_dx, format="%Y-%m-%d")
ci$date_firstvisit = as.Date(ci$date_firstvisit, format="%Y-%m-%d")
ci$date_onset = as.Date(ci$date_onset, format="%Y-%m-%d")
ci$date_presentation = as.Date(ci$date_presentation, format="%Y-%m-%d")
ci$date_sec_generalization = as.Date(ci$date_sec_generalization, format="%Y-%m-%d")
  
ci$entry2enrollment = round(as.numeric(difftime(ci$date_firstvisit, ci$date_entry, units="weeks"))/4)
ci$onset2presentation = round(as.numeric(difftime(ci$date_presentation, ci$date_onset, units="weeks"))/4)
ci$presentation2entry = round(as.numeric(difftime(ci$date_entry, ci$date_presentation, units="weeks"))/4)
ci$onset2dx = round(as.numeric(difftime(ci$date_dx, ci$date_onset, units="weeks"))/4)
ci$onset2secgen = round(as.numeric(difftime(ci$date_sec_generalization, ci$date_onset, units="weeks"))/4)

temp = ci[,c("onset2presentation","presentation2entry","entry2enrollment","onset2dx","onset2secgen")]
summary(temp)

length(which(ci$entry2enrollment <0))
ci[which(ci$entry2enrollment <0),]$pt_serial_no

length(which(ci$onset2presentation <0))
ci[which(ci$onset2presentation <0),]$pt_serial_no

length(which(ci$presentation2entry <0))
ci[which(ci$presentation2entry <0),]$pt_serial_no

length(which(ci$onset2dx <0))
ci[which(ci$onset2dx <0),]$pt_serial_no

length(which(ci$onset2secgen <0))
ci[which(ci$onset2secgen <0),]$pt_serial_no

melted = melt(temp)

melted = melted[!is.na(melted$value),]
melted_sub = melted[melted$value>=0,]

tbl = table(melted_sub$variable)

px = pretty(melted_sub$value)

labels = c(onset2presentation = sprintf("onset2presentation (n=%d)", tbl["onset2presentation"]),
           presentation2entry = sprintf("presentation2entry (n=%d)", tbl["presentation2entry"]),
           entry2enrollment = sprintf("entry2enrollment (n=%d)", tbl["entry2enrollment"]),
           onset2dx = sprintf("onset2dx (n=%d)", tbl["onset2dx"]),
           onset2secgen = sprintf("onset2secgen (n=%d)", tbl["onset2secgen"]))

p =  ggplot(melted_sub, aes(x=value, fill=variable))
p + geom_histogram(col="white") + 
  scale_x_continuous(breaks=px) + 
  facet_wrap(~variable, scales="free_y", nrow=2, labeller = labeller(variable=labels)) + 
  xlab("Time (months)") + theme_light() + theme(legend.position = "none") + 
  theme(strip.text.x = element_text(size=10, colour = "black"))

# MG composite score at enrollment 

ci$mgcs_firstvisit = factor(ci$mgcs_firstvisit)
summary(ci$mgcs_firstvisit)

temp = ci[!is.na(ci$mgcs_firstvisit),]
p = ggplot(temp, aes(x=mgcs_firstvisit))
p + geom_bar(fill="darkblue") + 
  ggtitle(sprintf("MG composite score at enrollment (n=%d)",nrow(temp))) +
  theme_light() + 
  xlab("MG composite score")

# course fu 

cf = read.csv("MGCK_course_fu_201611.csv", na.strings = c(""))
cf$date_visits = as.Date(cf$date_visits, format="%Y-%m-%d")
cf$pt_serial_no = factor(cf$pt_serial_no)

## change of MG composite score 

cf_mgcs = subset(cf, !is.na(mgcs))
nrow(cf_mgcs)
length(unique(cf_mgcs$pt_serial_no))  
summary(cf_mgcs)

cf_mgcs_sub = subset(cf_mgcs, date_visits >= "2014-01-01")
excl = subset(cf_mgcs, date_visits < "2014-01-01")
excl$pt_serial_no
length(excl$pt_serial_no)

mgcs_fu = cf_mgcs_sub[c("pt_serial_no", "date_visits", "mgcs")]
length(unique(mgcs_fu$pt_serial_no))

library(dplyr)
mgcs_fu %>%
  group_by(pt_serial_no) %>%
  arrange(pt_serial_no, date_visits) %>%
  mutate(visit_no = rank(date_visits), visit.total = n()) %>%
  mutate(time_int = round(as.numeric(date_visits - date_visits[1])/30))-> mgcs_fu

temp = mgcs_fu[duplicated(mgcs_fu$pt_serial_no),]

fu_mgcs = subset(mgcs_fu, mgcs_fu$pt_serial_no %in% temp$pt_serial_no)
fu_mgcs_no = length(unique(fu_mgcs$pt_serial_no))

p = ggplot(fu_mgcs, aes(x=date_visits, y=mgcs, col=factor(pt_serial_no), group=factor(pt_serial_no)))
p + geom_line() + geom_point() + 
  scale_x_date(date_labels = "%Y-%m-%d") + 
  theme_light() + 
  theme(legend.position = "none") +
  ggtitle(sprintf("Change of MG composite score (n=%d)", fu_mgcs_no)) + 
  xlab("Date of Visit") + 
  ylab("MG composite score")

p = ggplot(fu_mgcs, aes(x=time_int, y=mgcs, col=factor(pt_serial_no), group=factor(pt_serial_no)))
p + geom_line() + geom_point() + 
  theme_light() + 
  theme(legend.position = "none") +
  ggtitle(sprintf("Change of MG composite score (n=%d)", fu_mgcs_no)) + 
  xlab("Time from enrollment (month)") + 
  ylab("MG composite score")

# changes of MGFA class 

levels(cf$mgfa) = list(CSR = "CSR",
                       PR = "PR",
                       MM = "MM",
                       I = "I",
                       II = c("IIa", "IIb"),
                       III = c("IIIa", "IIIb"),
                       IV = c("IVa", "IVb"),
                       V = "V")

cf_mgfa = subset(cf, !is.na(mgfa))
nrow(cf_mgfa)
length(unique(cf_mgfa$pt_serial_no))  
summary(cf_mgfa)

cf_mgfa_sub = subset(cf_mgfa, date_visits >= "2014-01-01")
excl = subset(cf_mgfa, date_visits < "2014-01-01")
excl$pt_serial_no
length(excl$pt_serial_no)

mgfa_fu = cf_mgfa_sub[c("pt_serial_no", "date_visits", "mgfa")]
length(unique(mgfa_fu$pt_serial_no))

library(dplyr)
mgfa_fu %>%
  group_by(pt_serial_no) %>%
  arrange(pt_serial_no, date_visits) %>%
  mutate(visit_no = rank(date_visits), visit.total = n()) %>%
  mutate(time_int = round(as.numeric(date_visits - date_visits[1])/30))-> mgfa_fu

temp = mgfa_fu[duplicated(mgfa_fu$pt_serial_no),]

fu_mgfa = subset(mgfa_fu, mgfa_fu$pt_serial_no %in% temp$pt_serial_no)
fu_mgfa_no = length(unique(fu_mgfa$pt_serial_no))

p = ggplot(fu_mgfa, aes(x=date_visits, y=mgfa, col=factor(pt_serial_no), group=factor(pt_serial_no)))
p + geom_line() + geom_point() + 
  scale_x_date(date_labels = "%Y-%m-%d") + 
  theme_light() + 
  theme(legend.position = "none") +
  ggtitle(sprintf("Change of MGFA class (n=%d)", fu_mgfa_no)) + 
  xlab("Date of Visit") + 
  ylab("MGFA class")

p = ggplot(fu, aes(x=time_int, y=mgfa, col=factor(pt_serial_no), group=factor(pt_serial_no)))
p + geom_line() + geom_point() + 
  theme_light() + 
  theme(legend.position = "none") +
  ggtitle(sprintf("Change of MGFA class (n=%d)", fu_mgfa_no)) + 
  xlab("Time from enrollment (month)") + 
  ylab("MGFA class")

# remission 
rem = read.csv("MGCK_remission_201611.csv", na.strings = c(""))
# number of patients who achieved remission
# time2remission (dx2remission) 
# duration_remission
# number of patients who achieved remission but relapsed thereafter
# time2relapse (remission2relapse)

# crisis 
crisis = read.csv("MGCK_crisis_201611.csv", na.strings = c(""))
# number of patients who got crisis
crisis_sub = subset(crisis, !is.na(date_admission_mg_crisis))
length(unique(crisis_sub$pt_serial_no))
# number of crisis
crisis_tbl = table(crisis_sub$pt_serial_no)
sum(crisis_tbl)
# number of patients across different crisis frequency
table(crisis_tbl)

# time2crisis
crisis_sub$date_admission_mg_crisis = as.Date(crisis_sub$date_admission_mg_crisis, 
                                              format = "%Y-%m-%d")
temp = merge(crisis_sub, ci, by="pt_serial_no")
temp = subset(temp, !is.na(date_onset))
temp %>%
  select(pt_serial_no, date_onset, date_admission_mg_crisis) %>%
  mutate(time2crisis = round(as.numeric(
    difftime(temp$date_admission_mg_crisis, temp$date_onset, units = "weeks")
    )/4)) -> time2crisis_df

except.long.time2crisis = subset(time2crisis_df, time2crisis > 60) 
except.long.time2crisis

time2crisis_df_sub = subset(time2crisis_df, time2crisis <= 60)
time2crisis_df_sub %>%
  group_by(pt_serial_no) %>%
  arrange(date_admission_mg_crisis) -> time2crisis_df_sub

p = ggplot(time2crisis_df_sub, aes(x=factor(pt_serial_no), y=time2crisis))
p + geom_point() + geom_line() + 
  geom_segment(aes(x=factor(pt_serial_no), y=0, xend=factor(pt_serial_no), yend=time2crisis)) + 
  xlab("patient identifier") + ylab("Time from onset to crisis (months)") + 
  coord_flip()

# days_icu_stay
crisis_icu = subset(crisis, !is.na(days_icu_stay_mg_crisis))
hist(crisis_icu$days_icu_stay_mg_crisis, main = sprintf("ICU stay (n=%d)", nrow(crisis_icu)), col="darkblue", 
     xlab="Days") 

# thymectomy 
thymectomy = read.csv("MGCK_thymectomy_201611.csv", na.strings = c(""))
thymectomy$date_thymectomy = as.Date(thymectomy$date_thymectomy)
levels(thymectomy$thymectomy_type_resection) = list(transcervical_basic = c(1, "transcervical_basic"),
                                                    transcervical_extended = c(2, "transcervical_extended"),
                                                    transsternal_classic = c(3, "transsternal_classic"),
                                                    transsternal_extended = c(4, "transsternal_extended"),
                                                    transcervical_transsternal = c(5, "transcervical_transsternal"),
                                                    videoscopic_classic_VATS = c(6, "videoscopic_classic_VATS"),
                                                    videoscopic_extended_VATET = c(7, "videoscopic_extended_VATET"),
                                                    robot_surgery = c(8, "robot_surgery"),
                                                    others = c(9, "others"))

# number of patients who got thymectomy (excluding thymoma)
thymectomy_merged = merge(dx, thymectomy, by="pt_serial_no") 
thymectomy_nonthymoma = subset(thymectomy_merged, !thymus_dx == "thymoma") 
thymectomy_nonthymoma = subset(thymectomy_nonthymoma, !thymus_ct == "thymoma") 
thymectomy_thymoma = subset(thymectomy_merged, thymus_dx == "thymoma"|thymus_ct == "thymoma") 

thymectomy_nonthymoma_sub = subset(thymectomy_nonthymoma, !is.na(date_thymectomy))
thymectomy_thymoma_sub = subset(thymectomy_thymoma, !is.na(date_thymectomy))

time2thymectomy = merge(thymectomy_nonthymoma_sub, ci, by="pt_serial_no")
time2thymectomy %>%
  mutate(onset2thymectomy = round(as.numeric(difftime(date_thymectomy, date_onset, units = "weeks"))/4)) -> time2thymectomy

hist(time2thymectomy$onset2thymectomy, 
     main=sprintf("Time from onset to thymectomy (in cases of nonthymoma, n=%d)", nrow(time2thymectomy)),
     xlab = "Time from onset to thymectomy (months)", 
     ylab = "No. of patients", col="darkblue")

# thymectomy_type_resection

thymectomy_nonthymoma_tbl = table(thymectomy_nonthymoma_sub$thymectomy_type_resection)
thymectomy_thymoma_tbl = table(thymectomy_thymoma_sub$thymectomy_type_resection)

thymectomy_nonthymoma_tbl
thymectomy_thymoma_tbl


# pyrido
pyrido = read.csv("MGCK_pyrido_201611.csv", na.strings = c(""))

# steroid 
steroid = read.csv("MGCK_steroid_201611.csv", na.strings=c(""))
steroid$date_start_steroid = as.Date(steroid$date_start_steroid, format="%Y-%m-%d")
steroid$date_end_steroid = as.Date(steroid$date_end_steroid, format="%Y-%m-%d")

levels(steroid$steroid_route) = list(iv = c("iv", "i.v."),
                                     oral = "oral")

table(steroid$steroid_drug)
table(steroid$steroid_route)

length(unique(steroid$pt_serial_no))
steroid_iv = subset(steroid, steroid_route %in% c("iv", "i.v."))
length(unique(steroid_iv$pt_serial_no))

steroid_oral = subset(steroid, steroid_route == "oral")
length(unique(steroid_oral$pt_serial_no))

steroid_oral_sub = steroid_oral[c("pt_serial_no", "date_start_steroid", 
                                  "date_end_steroid",
                                  "steroid_dose")]  

steroid_dose = steroid_oral_sub[complete.cases(steroid_oral_sub),]

steroid_dose %>%
  group_by(pt_serial_no) %>%
  arrange(pt_serial_no, date_start_steroid) %>%
  mutate(steroid_tot = n()) -> steroid_dose

# wide2long format
steroid_dose_long = gather(steroid_dose, starend_point, date, date_start_steroid:date_end_steroid, factor_key = T)

steroid_dose_long %>%
  group_by(pt_serial_no) %>%
  arrange(pt_serial_no, date) %>%
  mutate(steroid_no = rank(date)) %>%
  mutate(time_int = as.numeric(date - date[1])) -> steroid_dose_long

p = ggplot(steroid_dose_long, aes(x=date, y=steroid_dose, 
                                  col=factor(pt_serial_no), 
                                  group=factor(pt_serial_no)))
p + geom_line() + geom_point() + 
  scale_x_date(date_labels = "%Y-%m-%d") + 
  theme_light() + 
  theme(legend.position = "none") +
  ggtitle(sprintf("Oral prednsiolone (n=%d)", length(unique(steroid_dose_long$pt_serial_no)))) + 
  xlab("Date of Visit") + 
  ylab("Dose (mg/day)")

p = ggplot(steroid_dose_long, aes(x=time_int, y=steroid_dose, 
                                  col=factor(pt_serial_no), 
                                  group=factor(pt_serial_no)))
p + geom_line() + geom_point() + 
  theme_light() + 
  theme(legend.position = "none") +
  ggtitle(sprintf("Oral prednisolone (n=%d)", length(unique(steroid_dose_long$pt_serial_no)))) + 
  xlab("Time (days)") + 
  ylab("Dose (mg/day)")

# istx 
istx = read.csv("MGCK_istx_201611.csv", na.strings = c(""))
istx$side_effects_is_tx = factor(istx$side_effects_is_tx)
levels(istx$is_tx_route) = list(iv = c("i.v.", "iv"),
                                oral = "oral") 
istx_use = subset(istx, !is.na(is_tx_drug))
length(unique(istx_use$pt_serial_no)) # number of patients treated with immunosuppressive agents

istx_mat = as.matrix(table(istx_use$pt_serial_no, istx_use$is_tx_drug))
istx_no = apply(istx_mat, 1, function(x)(length(which(x>0))))
table(istx_no) # number of patients who received N immunosuppressive agents in total 

istx_df = as.data.frame(table(istx_use$pt_serial_no, istx_use$is_tx_drug))
colnames(istx_df) = c("pt_serial_no", "drug", "Freq")

istx_df %>%
  filter(Freq>0) %>%
  group_by(drug) %>%
  summarize(n = n()) -> istx_df

istx_v = istx_df$n
names(istx_v) = istx_df$drug
sum(istx_v) 

dev.off()
pie(istx_v, labels=pielbls(istx_v), col=brewer.pal(length(istx_v), "Dark2"), 
    main=sprintf("Immunosuppressive agents (n=%d)", sum(istx_v)))

istx_complete = istx[complete.cases(istx[c("date_start_is_tx","date_end_is_tx")]),]
length(unique(istx_complete$pt_serial_no))

table(istx$side_effects_is_tx)

# ivig
ivig = read.csv("MGCK_ivig_201611.csv", na.strings = c(""))
ivig_use = subset(ivig, !is.na(date_start_ivig))
nrow(ivig_use)
length(unique(ivig_use$pt_serial_no))
table(table(ivig_use$pt_serial_no)) # number of ivig tx; number of patients 
table(ivig_use$side_effects_ivig)

# pex 
pex = read.csv("MGCK_pex_201611.csv", na.strings = c(""))
pex_use = subset(pex, !is.na(date_start_pex))
nrow(pex_use)
length(unique(pex_use$pt_serial_no))
table(table(pex_use$pt_serial_no)) # number of ivig tx; number of patients 
table(pex_use$side_effects_pex)

# outcome

outcome = read.csv("MGCK_outcome_201611.csv", na.strings = c(""))
ci_sub = ci[c("pt_serial_no", "date_firstvisit", "mgfa_firstvisit", "mgcs_firstvisit")]
outcome = merge(outcome, ci_sub, by="pt_serial_no")
outcome_sub = subset(outcome, !is.na(date_close))

# fu_duraton 
temp = outcome_sub[c("pt_serial_no", "date_firstvisit", "date_close")]
fu_duration_df = temp[complete.cases(temp),]
fu_duration_df$date_close = as.Date(fu_duration_df$date_close)
fu_duration_df %>%
  mutate(fu_duration = 
           round(as.numeric(difftime(date_close, date_firstvisit, 
                                     units = "weeks"))/4)) -> fu_duration_df

summary(fu_duration_df$fu_duration)

fu_duration_df[fu_duration_df$fu_duration > 60,]
fu_duration_df[fu_duration_df$fu_duration < 0,]

fu_duration_df_sub = subset(fu_duration_df, fu_duration <= 60 & fu_duration >= 0)

p = ggplot(fu_duration_df_sub, aes(x=fu_duration))
p + geom_histogram(fill="darkblue") + 
  ggtitle(sprintf("Follow-up duration (n=%d)", nrow(fu_duration_df_sub))) + 
  theme_light() + 
  xlab("Follow-up duration (months)")

table(outcome$mgfa_firstvisit)
table(outcome$mgfa_lastvisit)

levels(outcome$mgfa_firstvisit) = list(CSR = "CSR", 
                                       PR = "PR", 
                                       MM = "MM",
                                       I = "I",
                                       II = c("IIa", "IIb"),
                                       III = c("IIIa", "IIIb"),
                                       IV = c("IVa", "IVb"),
                                       V = "V")
levels(outcome$mgfa_lastvisit) = list(CSR = "CSR",
                                  PR = "PR",
                                  MM = "MM",
                                  I = "I",
                                  II = c("IIa", "IIb"),
                                  III = c("IIIa", "IIIb"),
                                  IV = c("IVa", "IVb"),
                                  V = "V")

outcome_mgfa = subset(outcome, !is.na(mgfa_lastvisit))
p = ggplot(outcome_mgfa, aes(x=factor(mgfa_lastvisit), fill=factor(mgfa_firstvisit)))
p + geom_bar(aes(y=(..count..)/sum(..count..)), stat = "count") + 
  scale_y_continuous(labels = scales::percent) +
  labs(y = "Percent", fill="MGFA class or PIS at enrollment") + 
  ggtitle(sprintf("MGFA class at enrollment & end of fu (n=%d)", sum(table(outcome_mgfa$mgfa_lastvisit)))) + 
  xlab("MGFA class at the end of fu") + theme_light() + theme(legend.position = "bottom") +
  coord_flip()

outcome_mgcs = outcome[complete.cases(outcome[c("mgcs_firstvisit", "mgcs_lastvisit")]),]
temp = outcome_mgcs[c("pt_serial_no", "mgcs_firstvisit", "mgcs_lastvisit")]
temp = gather(temp, visit, mgcs, mgcs_firstvisit:mgcs_lastvisit, factor_key = T)

pd = position_dodge(0.4)
p = ggplot(temp, aes(x=visit, y=jitter(as.numeric(mgcs)), col=factor(pt_serial_no), 
                     group=factor(pt_serial_no)))
p  + geom_line(position = pd, alpha=.5) + 
  geom_point(position = pd, alpha=.5) +
  theme_light() + scale_x_discrete(labels=c("Enrollment", "Last FU")) + 
  theme(legend.position = "none",
        axis.title.x = element_blank()) + 
  ylab("MG composite score") + 
  ggtitle(sprintf("Changes of MG composite score (n=%d)", length(unique(outcome_mgcs$pt_serial_no))))


