rm(list = ls())

#まずインストール
#install.packages("grf")
#install.packages("cowplot")
#install.packages("stargazer")


# Let's use the package GRF - Generalized Random Forest
library(grf)
library(tidyverse)
library(cowplot)
library(stargazer) #元々はコメントアウトされていた-->使わないのかな？


#wd1 <- c("/Users/mic965/")
#wd1 <- (paste0("/Users/mic965", Sys.getenv("USERNAME"), "/Dropbox/cariplo/Michela/Data/replication_files/dataset/"))
#wd2 <- (paste0("/Users/mic965", Sys.getenv("USERNAME"), "/Dropbox/cariplo/Michela/Data/replication_files/output/"))
#俺の実行環境に合わせて以下のpathに変更
wd1 <- "/Users/domold/Library/CloudStorage/GoogleDrive-domokomod5@gmail.com/My Drive/Learning/GoalsAndGaps_replication_files_ECMA/dataset/others/"

# My favourite explanation is here: https://www.markhw.com/blog/causalforestintro
# Upload data of the RCT
students_program <- read.table(paste0(wd1,"dataset_causalforest.txt"),header=T,sep="\t")


###################################################################################
## 0. 俺のデータ探索
###################################################################################
students_program <- as_tibble(students_program)
students_program
#オブジェクトのクラスを確認
class(students_program)
#各変数の四分位と平均とminとmaxを見られる=pandasのdf.describeみたいな関数
summary(students_program)
#変数名を確認
colnames(students_program)
#pandasのdf.infoみたいな関数
str(students_program)
#ssは何？-->schoolの数？--> 単純にseed. 意味はないみたい.
length(unique(students_program$school))
n_distinct(students_program)
#category変数をcategory型に
students_program[, 17:22] <- as_factor(students_program[, 17:22]) 
str(students_program)
class(students_program$province)
#うまくいっていない
students_program$province <- as_factor(students_program$province)
students_program$educmother <- as_factor(students_program$educmother)
students_program$educfather <- as_factor(students_program$educfather)
students_program$occmother <- as_factor(students_program$occmother)
students_program$occfather <- as_factor(students_program$occfather)
students_program$citizenship <- as_factor(students_program$citizenship)
students_program$school <- as_factor(students_program$school)

###################################################################################
 ## 1. Heterogeneous effects on lictec2
 ###################################################################################
 ss<- 1839
  set.seed(ss)
  
  # Let's run the causal forest now
  cf <- causal_forest(
    X = model.matrix(~ ., data = students_program[, 12:ncol(students_program)]),
    Y = students_program$lictec2,
    W = students_program$treat,
    num.trees = 100000,
    clusters= students_program$school,
    seed = ss
  )
  
  # I then predict thetestata, tell?rf?o include variance estimates, 
  # and then I assign the predictions (i.e., the estimated treatment effects) 
  # to the?test?data frame so that we can use these in subsequent analyses:
  
  preds <- predict(
    object = cf, 
    newdata = NULL, 
    estimate.variance = TRUE
  )
  
  students_program$preds <- preds$predictions
  students_program$sqrt <-  sqrt(preds$variance.estimates)
students_program$excesserror <-  preds$excess.error
students_program$debiasederror <-  preds$debiased.error
  # Variable Importance
Variable_Importance <- cf %>% 
    variable_importance() %>% 
    as_tibble() %>% 
    mutate(variable = colnames(cf$X.orig)) %>% 
    arrange(desc(V1))
Variable_Importance
write.csv(Variable_Importance, file="Variable_Importance.csv")


###################################################################################
students_program$mom_working_class <- 0
students_program$mom_working_class[students_program$occmother==2] <- 1
students_program$mom_high_class <- 0
students_program$mom_high_class[students_program$occmother==1] <- 1
students_program$mom_home <- 0
students_program$mom_home[students_program$occmother==3] <- 1
students_program$mom_unemp <- 0
students_program$mom_unemp[students_program$occmother==4] <- 1
students_program$mom_miss <- 0
students_program$mom_miss[students_program$occmother==5] <- 1

students_program$dad_working_class <- 0
students_program$dad_working_class[students_program$occfather==2] <- 1
students_program$dad_high_class <- 0
students_program$dad_high_class[students_program$occfather==1] <- 1
students_program$dad_home <- 0
students_program$dad_home[students_program$occfather==3] <- 1
students_program$dad_unemp <- 0
students_program$dad_unemp[students_program$occfather==4] <- 1
students_program$dad_miss <- 0
students_program$dad_miss[students_program$occfather==5] <- 1

students_program$mom_educ_uni <- 0
students_program$mom_educ_uni[students_program$educmother==1] <- 1
students_program$mom_educ_hs <- 0
students_program$mom_educ_hs[students_program$educmother==2] <- 1
students_program$mom_educ_lhs <- 0
students_program$mom_educ_lhs[students_program$educmother==3] <- 1
students_program$mom_educ_mis <- 0
students_program$mom_educ_mis[students_program$educmother==4] <- 1

students_program$dad_educ_uni <- 0
students_program$dad_educ_uni[students_program$educfather==1] <- 1
students_program$dad_educ_hs <- 0
students_program$dad_educ_hs[students_program$educfather==2] <- 1
students_program$dad_educ_lhs <- 0
students_program$dad_educ_lhs[students_program$educfather==3] <- 1
students_program$dad_educ_mis <- 0
students_program$dad_educ_mis[students_program$educfather==4] <- 1


students_program$std_cit_latin <- 0
students_program$std_cit_latin[students_program$citizenship ==1] <- 1
students_program$std_cit_afric <- 0
students_program$std_cit_afric[students_program$citizenship ==2] <- 1
students_program$std_cit_asia <- 0
students_program$std_cit_asia[students_program$citizenship ==3] <- 1
students_program$std_cit_easteur <- 0
students_program$std_cit_easteur[students_program$citizenship ==4] <- 1


students_program$province_pd <- 0
students_program$province_pd[students_program$province ==1] <- 1
students_program$province_bs <- 0
students_program$province_bs[students_program$province ==2] <- 1
students_program$province_mi <- 0
students_program$province_mi[students_program$province ==3] <- 1
students_program$province_to <- 0
students_program$province_to[students_program$province ==4] <- 1
students_program$province_ge <- 0
students_program$province_ge[students_program$province ==5] <- 1

write.csv(students_program,file="ore_no_causalforest.csv")
