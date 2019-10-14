# Package Utils 

package_installed <- function(pkg, auto_install = FALSE){
  mis = system.file('', package = pkg) == ''
  if(mis && auto_install){
    utils::install.packages(pkg)
    mis = system.file('', package = pkg) == ''
  }
  !mis
}

# Dirty checks
package_installed('shiny', auto_install = TRUE)
package_installed('rmarkdown', auto_install = TRUE)
package_installed('knitr', auto_install = TRUE)
package_installed('stringr', auto_install = TRUE)
package_installed('rstudioapi', auto_install = TRUE)

check_dir <- function(){
  wd = normalizePath(getwd())
  wd_check = normalizePath(file.path(dirname(wd), 'owlserver'))
  if( wd != wd_check ){
    stop('Please make sure your working directory is set as project directory!')
  }
}

insert_block <- function(file, anchor_start, anchor_end, content, append = FALSE){
  s = readLines(file)
  trimmed = stringr::str_trim(s)
  
  tryCatch({
    start = which(trimmed == anchor_start)[1]
    end = which(trimmed == anchor_end)[1]
    if(append && (end - start) >= 2){
      blk = s[(start+1):(end-1)]
    }else{
      blk = NULL
    }
    s = c(s[1:start], blk, content, s[end:length(s)])
    writeLines(s, file)
    return(end)
  }, error = function(e){
    stop(sprintf('Cannot parse %s. The file is corrupted.', file))
  })
  
}

add_user <- function(user){
  if(!stringr::str_detect(user, '^[a-zA-Z0-9_]+$')) stop('username must only contains letters, digits, and "_"!')
  check_dir()
  if(dir.exists(user)) stop(sprintf('a folder %s already exists', user))
  user_md = sprintf('%s.md', user)
  if(file.exists(user_md)) stop(sprintf('a markdown file %s.md already exists', user))
  
  dir.create(file.path(user, 'assets'), recursive = TRUE)
  
  # Read file from shared/template/user.md
  s = readLines('./shared/template/user.md')
  s = paste(s, collapse = '\n')
  s = stringr::str_replace_all(s, '%s', user)
  writeLines(s, con = user_md)
  
  # Add to index.rmd
  user_formal = stringr::str_replace_all(user, '[_]+', ' ')
  user_formal = stringr::str_to_title(user_formal)
  line = insert_block( file = './contributors.md' , 
                anchor_start = '<!-- start-contributors -->',
                anchor_end = '<!-- end-contributors -->',
                content = sprintf('* [%s](%s.html)', user_formal, user),
                append = TRUE)
  
  collect_user_topics(user)
  
  rstudioapi::navigateToFile('./contributors.md', line = line)
  rstudioapi::navigateToFile(user_md)
}

collect_user_topics <- function(user){
  check_dir()
  if(!dir.exists(user)) stop(sprintf('user folder %s not found. Use add_user("%s") to create user', user, user))
  user_md = sprintf('%s.md', user)
  if(!file.exists(user_md)) stop(sprintf('user markdown file %s.md not found. Use add_user("%s") to create user', user, user))
  
  # collect topics:
  pattern = sprintf('^%s-([a-zA-Z0-9_]+)-([a-zA-Z0-9_]+).[rR]{0,1}[mM][dD]$', user)
  fs = list.files('.', pattern = pattern)
  if(!length(fs)){
    re = '(No topics yet...)'
  }else{
    mt = as.data.frame(stringr::str_match(fs, pattern), stringsAsFactors = FALSE)
    names(mt) = c('fname', 'topic', 'title')
    parse_title = function(s){
      idx = stringr::str_extract(s, '^[0-9]+')
      idx = as.numeric(idx)
      
      tp = stringr::str_replace_all(s, '[_]+', ' ')
      tp = stringr::str_trim(tp)
      tp = stringr::str_to_title(tp)
      list(order = idx, title = tp)
    }
    tags = htmltools::tags
    tmp = parse_title(mt$topic)
    mt$topic = tmp$title
    mt$topic_order = tmp$order
    tmp = parse_title(mt$title)
    mt$title = tmp$title
    mt$title_order = tmp$order
    
    mt$link = stringr::str_replace(mt$fname, '.[rR]{0,1}[mM][dD]$', '.html')
    
    mt = mt[order(mt$topic_order, mt$title_order),]
    
    re = unlist(lapply(unique(mt$topic), function(tp){
      sub = which(mt$topic %in% tp)
      c(
        sprintf('#### %s', tp),
        unlist(sapply(sub, function(ii){
          row = mt[ii, ]
          sprintf('* [%s](%s)', row$title, row$link)
        })),
        ''
      )
    }))
    
    s = readLines(user_md)
    trimmed = stringr::str_trim(s)
    
    tryCatch({
      start = which(trimmed == '<!-- begin-of-index -->')[1]
      end = which(trimmed == '<!-- end-of-index -->')[1]
      s = c(s[1:start], re, s[end:length(s)])
      writeLines(s, user_md)
    }, error = function(e){
      stop(sprintf('Cannot parse %s.md. The file is corrupted.', user))
    })
    
  }
  
}
