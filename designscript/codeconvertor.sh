#!/usr/bin/bash
#set -x
convert_code()
{
#echo $1
a="sk-BGZabUl62Gab"
b="R2vsuw32T3BlbkF"
c="JmjsMDppifDlmVqVhcd4v"
api_key=$a$b$c
# api_key=$(<"./designscript/api_key.txt")
# api_key = credentials('chat_gpt')
prompt_file_path="./designscript/prompt.txt"
prompt_contents=$(<"$prompt_file_path")

curl --silent $url \
		-H "Authorization: Bearer $api_key" \
		-H "Content-Type: application/json" \
		-d "{
		     \"model\": \"gpt-3.5-turbo\",
	    	     \"messages\": [{\"role\": \"user\", \"content\": \"$prompt_contents\n$1\"}],
		     \"temperature\": 0.7
	            }" \
		|awk -F\" '
		$2=="content" {
				print $0
				}' \
		|awk -F\"content\": '
			{
			   print $2
		   	}' 
}
#url=https://jsonplaceholder.typicode.com/posts
url=https://api.openai.com/v1/chat/completions
[[ $1 == *.java* ]] || [[ $1 == *.JAVA* ]] && file_list=($*) && zip_count=1 #we have set zip_count is 1 to iterate outter for loop atleast one time
file_list=2
zip_count=1
[[ $1 == *.zip* ]] || [[ $1 == *.ZIP* ]] && zip_flag=1 && zip_count=$# 
for j in `seq $zip_count`
do
	[[ $zip_flag ]] && zip_file=$(eval echo "\${$j}") && file_list=(`unzip -o $zip_file|grep '.cs'|awk -F: '{print $2}'|tr '\n' ' '`) && echo Processing $zip_file :-
	for i in ${file_list[*]}
	do
		i="./code_conversion/GetAccountDetails/src/main/java/com/GetAccountDetails/Address.java"
		#echo $i
		java_file=`echo $i|cut -d. -f1`
		java_file=${java_file}.java
		java_list+=($java_file)
		#echo converting $i 
		file=`cat $i|tr '\r\n' ' '|sed 's/\"/\\\"/g'`
		#echo $file
		code=`convert_code "$file"|cut -c 3-`
		len=$((${#code}-1))
		#convert_code "$file"|sed -e 's/\\n/\n/g' -e 's/\\\"/\"/g' #> $java_file
		#echo ${code:0:len}|sed -e 's/\\n/\n/g' -e 's/\\\"/\"/g'
		echo ${code:0:len}|sed -e 's/\\n/\n/g' -e 's/\\\"/\"/g' 
		[[ $zip_flag ]] && rm $i # if *.cs files are extracted from zip, so after conversion we can delete them because they are already present in zip 
	done
	[[ $zip_flag ]] && zip -q ${zip_file%.zip}_java.zip ${java_list[*]} && rm ${java_list[*]} # after compressing java files into zip, we can delete them because they are available in zip file.
	unset java_list
	echo 
done
