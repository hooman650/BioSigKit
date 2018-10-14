# Contribution Guidelines

## Reporting issues

- **Search for existing issues (Both "closed" and "Open").** Please check to see if someone else has reported the same issue.
- **Report your operating system and Matlab version.**
- **Share as much information as possible.** Include operating system and version, browser and version. Also, include steps to reproduce the bug.
- **Be patient.**

## Project Installation
Refer to the [README](README.md).


## Code Style

### Contributing to GUI
The GUI relies on external libraries. The GUI has only been tested on Windows operating systems (10, 8 and 7)
Please do include any third party library and make sure that you have appropriate licensing to use third party materials.

### Adding new algorithms
Please only add the new algorithms under the Algorithms directory of the reposirty and update the code map. Please add clear helper headers at the begining of your function for clear instructions.
The added subroutines need to be included in the BioSigKit constructor. Once you added a new routine please comment and date it.

### Variable Naming
Not all current code follows the conventions below but these will be followed for future developments. 
- `lowerCamelCase` General variables
- `UpperCamelCase` Functions
- Maximize the use  of semantic and descriptive variables names (e.g. `faceIndices` not `fcInd` or `fi`). Avoid abbreviations except in cases of industry wide usage. In some cases non-descriptive and short variable names are exceptable for instance vertices (points), faces, edges, colors and logic arrays may be denoted `V`, `F`, `E`, `C`, `L`. Furthermore, if a mathematrical symbol or letter is commonly used for some entity it may be acceptable to use short names e.g. coordinates may be referred to as `X`, `Y` and `Z` and image coordinates of indices may be referred to as `I`, `J` and `K`. In some cases the use of capital or non-capital letters refers to tensors/matrices/arrays/sets and scalars/components/subsets respectively, e.g. a multitude of scalars `c` may be contained within an array or matrix `C`, or a cell array `D` may contain individual entries referred to as `d`. 

## Testing
Currently, demo.m can be used to test all the subroutines of the toolbox. 

## Pull requests
- Try not to pollute your pull request with unintended changes – keep them simple and small. If possible, squash your commits.
- Try to share how your code has been tested before submitting a pull request.
- If your PR resolves an issue, include **closes #ISSUE_NUMBER** in your commit message (or a [synonym](https://help.github.com/articles/closing-issues-via-commit-messages)).
- Review
    - If your PR is ready for review, another contributor will be assigned to review your PR
    - The reviewer will accept or comment on the PR. 
    - If needed address the comments left by the reviewer. Once you're ready to continue the review, ping the reviewer in a comment.
    - Once accepted your code will be merged to `master`
