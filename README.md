## ForestSAT 2018 Conference Registration System
### University of Maryland / NASA Goddard Space Flight Center

The annual ForestSAT conference supports research in satellite remote sensing for monitoring and analysis of world-wide forest health.  The conference registration system allows user registration, submission of scientific papers, and review/evaluation of paper submissions. Scheduling and calendar display functionality is also under development. 

##### description
The project is being developed with a Ruby-on-Rails/Postgres backend and Javascipt/jquery frontend interface.  Users register an account with confirmation email, then submit scientific paper abstracts for consideration.  Front-end validation and text entry functions facilitate submission of abstract details by individual authors.  Authors may also select up to three topical "keywords" for later use in assigning papers to specific sessions during the conference.

The abstract review system allows administrators to select reviewers, assign them to specific papers, view recommendations and comments, then make final selections for inclusion at the conference.  After evaluating abstract submissions, the designated reviewers can assign a grade to the submission, recommend a presentation type (oral, poster or both) and enter comment statements to clarify their thinking.  Conference administrators may then select or reject submissions based on reviewer recommendations.  

Additional functionality, currently in development, will include a scheduling system for assigning selected papers to conference sessions and displaying an interactive calendar.

##### database
The Postgres database includes tables for users, authors, author affiliations, abstracts and conference sessions; it is designed to support numerous many-to-many relationships amongst the various authors and affiliations while avoiding duplication of data.
