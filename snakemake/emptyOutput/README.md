# Empty output

A bash script that does coinflip to generate either empty or non-empty file.  
Add condition to check if the output is empty or not.

Bash commands:

`bash coinflip.sh && [[ -s out.txt ]] && echo "result generated" || echo "empty file"`

`&` Run in the background  
`&&` Only run when first command is successfully executed.  
`||` Logical  
`;` Separator, does not care about first command  

Reference:  

https://www.gnu.org/savannah-checkouts/gnu/bash/manual/bash.html  
https://stackoverflow.com/questions/4510640/what-is-the-purpose-of-in-a-shell-command
