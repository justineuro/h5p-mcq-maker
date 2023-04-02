#/bin/bash


#####
# remove the old pretty versions: h5p-pr.json, content-pr.json, if they exist
#####
if [ -f "./h5p-pr.json" ]; then rm ./h5p-pr.json; fi
if [ -f "./content-pr.json" ]; then rm ./content-pr.json; fi
sleep 3s # pause for a while

#####
# * read the control parameters in the control.txt file; these are
# TITLE: the title of the H5P, set to "THIS IS THE TITLE" as default
# AUTHOR: the name in the author field, set to "I am The Author" as default
# LICENSE: the license, set to ODC PDDL as default
# INTRODUCTION: some blurb about the H5P
# PASS_PERCENTAGE: set to 50% as default
# DISABLE_BACKWARDS_NAVIGATION: set to false as default
# RANDOM_QUESTIONS: set to true as default
# POOL_SIZE: set to five (5) as default as there are 10 questions total
# N_QUESTIONS: there are 10 questions in the myMCQuestions.txt file
#
# * print to stdout the value of these parameters
#
#####
echo -e "The following control parameters were set for the H5P to be made:"
n_lines=1
while read line
do 
	echo $line
	export "$line"
	n_lines=`expr $nlines_n + 1`
done < ./control.txt

#####
# create h5p.json based on the values of the control parameters read for
# TITLE, AUTHOR, and LICENSE
#####
cat > h5p-pr.json << EOT
{
  "title": $TITLE,
  "language": "und",
  "mainLibrary": "H5P.QuestionSet",
  "embedTypes": [
    "div"
  ],
  "authors": [
    {
      "name": $AUTHOR,
      "role": "Author"
    }
  ],
  "license": $LICENSE,
  "defaultLanguage": "en",
  "preloadedDependencies": [
    {
      "machineName": "H5P.Image",
      "majorVersion": "1",
      "minorVersion": "1"
    },
    {
      "machineName": "H5P.MultiChoice",
      "majorVersion": "1",
      "minorVersion": "16"
    },
    {
      "machineName": "FontAwesome",
      "majorVersion": "4",
      "minorVersion": "5"
    },
    {
      "machineName": "H5P.JoubelUI",
      "majorVersion": "1",
      "minorVersion": "3"
    },
    {
      "machineName": "H5P.Transition",
      "majorVersion": "1",
      "minorVersion": "0"
    },
    {
      "machineName": "H5P.FontIcons",
      "majorVersion": "1",
      "minorVersion": "0"
    },
    {
      "machineName": "H5P.Question",
      "majorVersion": "1",
      "minorVersion": "5"
    },
    {
      "machineName": "H5P.DragQuestion",
      "majorVersion": "1",
      "minorVersion": "14"
    },
    {
      "machineName": "jQuery.ui",
      "majorVersion": "1",
      "minorVersion": "10"
    },
    {
      "machineName": "H5P.QuestionSet",
      "majorVersion": "1",
      "minorVersion": "20"
    },
    {
      "machineName": "H5P.Video",
      "majorVersion": "1",
      "minorVersion": "6"
    }
  ]
}
EOT

#####
# create the top part of the content-pr.json; use the values of 
# INTRODUCTION, PASS_PERCENTAGE, DISABLE_BACKWARDS_NAVIGATION, 
# RANDOM_QUESTIONS, and POOL_SIZE
#####
cat >> content-pr.json << EOT
{
  "introPage": {
    "showIntroPage": true,
    "startButtonText": "Start Quiz",
    "title": $TITLE,
    "introduction": "<p>${INTRODUCTION:1:-1}<br>\n&nbsp;</p>\n"
  },
  "progressType": "dots",
  "passPercentage": $PASS_PERCENTAGE,
  "disableBackwardsNavigation": $DISABLE_BACKWARDS_NAVIGATION,
  "randomQuestions": $RANDOM_QUESTIONS,
  "endGame": {
    "showResultPage": true,
    "showSolutionButton": true,
    "showRetryButton": true,
    "noResultMessage": "Finished",
    "message": "Your result:",
    "scoreBarLabel": "You got @finals out of @totals points",
    "overallFeedback": [
      {
        "from": 0,
        "to": 100
      }
    ],
    "solutionButtonText": "Show solution",
    "retryButtonText": "Retry",
    "finishButtonText": "Finish",
    "submitButtonText": "Submit",
    "showAnimations": false,
    "skippable": false,
    "skipButtonText": "Skip video"
  },
  "override": {
    "checkButton": true
  },
  "texts": {
    "prevButton": "Previous question",
    "nextButton": "Next question",
    "finishButton": "Finish",
    "submitButton": "Submit",
    "textualProgress": "Question: @current of @total questions",
    "jumpToQuestion": "Question %d of %total",
    "questionLabel": "Question",
    "readSpeakerProgress": "Question @current of @total",
    "unansweredText": "Unanswered",
    "answeredText": "Answered",
    "currentQuestionText": "Current question",
    "navigationLabel": "Questions"
  },
  "poolSize": $POOL_SIZE,
  "questions": [
EOT


i=1 # line number from input.txt
q=0 # indicator if the question part in an item has been processed
n=1 # counter for pool size
declare -a arrline
while read line
do
	#echo $i
	#echo "n = " $n
	# if this is a question line, write question
	if [ "$q" == "0" ]; then 
		#echo "$line"
		#echo "JSON for question part being written"
		arrline=(`echo -e $line`)
		line=`unset arrline[0]; echo ${arrline[*]}`
		cat >> content-pr.json << EOT
	{
		"library": "H5P.MultiChoice 1.16",
		"params": {
			"question": "$line",
			"answers": [
EOT
		q=`expr $q + 1` # indicator q set to 1
	elif [ "${line:0:1}" == "" ]; then  # blank line or end of question
		#echo "$line"
		#echo  "JSON for end of question, after last choice has been processed"
		cat >> content-pr.json << EOT
					}
				],
				"behaviour": {
					"enableRetry": true,
					"enableSolutionsButton": true,
					"enableCheckButton": true,
					"type": "auto",
					"singlePoint": false,
					"randomAnswers": true,
					"showSolutionsRequiresInput": true,
					"confirmCheckDialog": false,
					"confirmRetryDialog": false,
					"autoCheck": false,
					"passPercentage": 100,
					"showScorePoints": true
				},
				"media": {
					"disableImageZooming": false
				},
				"overallFeedback": [
					{
						"from": 0,
						"to": 100
					}
				],
				"UI": {
					"checkAnswerButton": "Check",
					"showSolutionButton": "Show solution",
					"tryAgainButton": "Retry",
					"tipsLabel": "Show tip",
					"scoreBarLabel": "You got :num out of :total points",
					"tipAvailable": "Tip available",
					"feedbackAvailable": "Feedback available",
					"readFeedback": "Read feedback",
					"wrongAnswer": "Wrong answer",
					"correctAnswer": "Correct answer",
					"shouldCheck": "Should have been checked",
					"shouldNotCheck": "Should not have been checked",
					"noInput": "Please answer before viewing the solution",
					"a11yCheck": "Check the answers. The responses will be marked as correct, incorrect, or unanswered.",
					"a11yShowSolution": "Show the solution. The task will be marked with its correct solution.",
					"a11yRetry": "Retry the task. Reset all responses and start the task over again."
				},
				"confirmCheck": {
					"header": "Finish ?",
					"body": "Are you sure you wish to finish ?",
					"cancelLabel": "Cancel",
					"confirmLabel": "Finish"
				},
				"confirmRetry": {
					"header": "Retry ?",
					"body": "Are you sure you wish to retry ?",
					"cancelLabel": "Cancel",
					"confirmLabel": "Confirm"
				}
			},
			"subContentId": "`uuidgen`",
			"metadata": {
				"contentType": "Multiple Choice",
				"license": "U",
				"title": "Untitled Multiple Choice"
			}
EOT
		# if this is NOT the last question in the pool
		if [ "$n" -lt "$N_QUESTIONS" ]; then
			cat >> content-pr.json << EOT
		},
EOT
		else # this is for the last choice for the last question in the pool
			cat >> content-pr.json << EOT
		}
EOT
		fi
			q=0 # set q to zero for next question line to be written
			n=`expr $n + 1` # increase counter for pool size
		# if this is a correct answer choice ...
	elif [ "${line:0:1}" == "*" ]; then 
		#echo "$line"
		#echo "write JSON for a correct answer choice"
		#if this is the first of the given choices 
		if [ "$q" == "1" ]; then
			cat >> content-pr.json << EOT
					{
						"text": "${line#'*'}",
						"correct": true,
						"tipsAndFeedback": {}
EOT
			q=`expr $q + 1`
		else # if (q=2) this is NOT the first of the given choices
			cat >> content-pr.json << EOT
					},
					{
						"text": "${line#'*'}",
						"correct": true,
						"tipsAndFeedback": {}
EOT
		fi
	else # this must be a wrong answer line
		#echo "$line"
		#echo "write JSON for wrong answer line"
		#if this is the first of the given choices 
		if [ "$q" == "1" ]; then 
			cat >> content-pr.json << EOT
					{
						"text": "${line}",
						"correct": false,
						"tipsAndFeedback": {}
EOT
			q=`expr $q + 1`
		else # if (q=2) this is NOT the first of the given choices
			cat >> content-pr.json << EOT
					},
					{
						"text": "${line}",
						"correct": false,
						"tipsAndFeedback": {}
EOT
		fi
	fi
	i=`expr $i + 1`
done < $1
cat >> content-pr.json << EOT
	]
}
EOT

#####
# delete old h5p.json, content/content.json, if they exist 
# then replace with the minified JSON files
#####
if [ -f "./h5p.json" ]; then rm ./h5p.json; fi
if [ -f "./content/content.json" ]; then rm ./content/content.json; fi
echo -e "\nMinifying the JSON files ...\n"
sleep 3s # pause for a while
script -q -c "jq -c -M < ./h5p-pr.json"; sed -n '2p' typescript | sed 's/.$//' > h5p.json
script -q -c "jq -c -M < ./content-pr.json"; sed -n '2p' typescript | sed 's/.$//' > content.json
rm typescript

#####
# set color tags (not all needed)
####
BLACK='\e[1;30m'
RED='\e[1;31m'
GREEN='\e[1;32m'
YELLOW='\e[1;33m'
BLUE='\e[1;34m'
BOLD='\e[1;39m'
BLINK='\e[5m'
OBLINK='\e[25m'
NORM='\e[0m'

mv ./h5p-pr.json ./myNewH5P-mcq
mv ./h5p.json ./myNewH5P-mcq
mv ./content-pr.json ./myNewH5P-mcq/content
mv ./content.json ./myNewH5P-mcq/content
if [ -e "./myNewH5P-mcq.h5p" ]; then rm ./myNewH5P-mcq.h5p; fi
cd myNewH5P-mcq
zip -r -D -X ../myNewH5P-mcq.h5p * >/dev/null
cd $OLDPWD
sleep 2s
echo -e "\nThe h5p.json file was created in this directory: ${BOLD}${YELLOW}./myNewH5P-mcq/h5p.json${NORM}"
echo -e "The content.json that was created is in: ${BOLD}${YELLOW}./myNewH5P-mcq/content/content.json${NORM}"
echo -e "The newly created multiple-choice H5P is in this directory: ${BOLD}${YELLOW}./myNewH5P-mcq.h5p${NORM}\n"
###
##
#
