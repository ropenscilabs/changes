#' Record Changes in Files under Version Control.
#'
#' TODO Describe this better.
#'
#' @param message character: the message to be added to the version control
#'   checkpoint.
#'
#' @importFrom git2r add commit
#'
#' @export
record <- function (message) {
  
  repo <- get_repo()

  if (!head_at_master(repo)) {
    
    # We are in detached head state...
    # commit the diffs to master->head  on top and linearize.
    cat("You are currently behind the latest version.\n")
    cat("Do you want to add your changes and make this the latest version? [Yes/No]? ")
    answer <- readLines(n = 1, warn = FALSE)
    if (!any(c("y", "ye", "yes") %in% tolower(answer)))
      return (invisible(NULL))

    git2r::stash(repo)  # call_system("git", "stash")
    git2r::checkout(repo, "master")
    
    n_commits <- length(git2r::commits(repo))
    retrieve(n_commits)
    # git2r::stash_drop(repo) 
    call_system("git", "stash pop")
  }
  
  # check the message
  message <- check_message(message)

  # Stage unstaged changes
  git2r::add(repo, "*")
  
  # see if there's anything to commit
  any_unstaged <- nrow(diff_df(repo, staged = FALSE)) > 0
  any_staged <- nrow(diff_df(repo, staged = TRUE)) > 0
  
  if (any_staged | any_unstaged) {
    capture.output(git2r::commit(repo, message = message))
  } else {
    cat ("no files have changed since your last record,",
             "there's nothing to commit")
  }
  
  invisible(NULL)
  
}

