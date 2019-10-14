---
title: "%s"
---

<!-- Start your brief intro here -->

This is your member site. Please leave all anchors like `<!--`, `-->` **as is** in this document. They are used to automatically manage the topics.

1. To create a valid topic, please create `md` or `rmd` files in project directory using the following syntax:
```
%s-my_topic_name-article_title.md
%s-my_topic_name-article_title.rmd
```
For example, a file named `bob-2_clustering_method-1_introduction` will gain a topic `2 Clustering Method` with title `1 Introduction` here.

2. To compile your work, simply go to RStudio tabpanel `Build` > press `Build Website`.

3. To automatically manage your topics and add them to this file, run the following commands
```
source('shared/template-utils.R')
collect_user_topics("%s")
```

#### Index Topics (%s)

<!-- 
This file can be automatically managed unless you don't want it. 
Please do not edit anything between line "begin-of-index" and "end-of-index"
-->
<!-- begin-of-index -->
<!-- end-of-index -->

<!-- Start your other stuff here -->
