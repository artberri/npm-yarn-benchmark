#!/bin/bash
# Benchmark runner
# Based on https://gist.github.com/peterjmit/3864743

repeats=3
output_folder='reports'
libraries=('angular2' 'ember' 'react')
tools=('yarn' 'ied' 'pnpm' 'npm')
base_dir=$PWD

# Option parsing
while getopts n:o: OPT
do
    case "$OPT" in
        n)
            repeats=$OPTARG
            ;;
        o)
            output_folder=$OPTARG
            ;;
        \?)
            echo 'No arguments supplied'
            exit 1
            ;;
    esac
done

shift `expr $OPTIND - 1`

output_folder="${base_dir}/${output_folder}"

mkdir -p $output_folder

echo 'Benchmarking: Yarn vs. IED vs. PNPM vs. NPM'
echo '==========================================='
echo 'Running' $repeats 'times per library, test results will be stored in' $output_folder 'directory'
echo ''

run_tests() {
    for tool in "${tools[@]}"
    do
        avg_file_cc="${output_folder}/avg_${tool}_1.csv"
        avg_file="${output_folder}/avg_${tool}_0.csv"
        echo -n > $avg_file_cc
        echo -n > $avg_file
    done

    for library in "${libraries[@]}"
    do
        echo $library '=>';
        for tool in "${tools[@]}"
        do
            run_benchmark $tool 1 $library # Cleaning cache
            run_benchmark $tool 0 $library # Without cleaning cache
        done
    done
}

run_benchmark() {
    tool=$1
    clean_cache=$2
    library=$3
    directory="${base_dir}/libraries/${library}"
    output_file="${output_folder}/${tool}_${clean_cache}_${library}.csv"
    avg_file="${output_folder}/avg_${tool}_${clean_cache}.csv"

    echo -n > $output_file

    case "$tool" in
        yarn)
            command_to_run='yarn install'
            command_to_clear_cache='yarn cache clean'
            ;;
        ied)
            command_to_run='ied install'
            command_to_clear_cache='ied cache clean'
            ;;
        pnpm)
            command_to_run='pnpm install'
            command_to_clear_cache='pnpm cache clean'
            ;;
        npm)
            command_to_run='npm install --cache-min 999999'
            command_to_clear_cache='npm cache clean'
            ;;
        *)
            exit 1
            ;;
    esac

    cd $directory

    if [ $clean_cache = 1 ]; then
        cache_text='with clean cache'
    else
        cache_text=''

        # Install once to generate cache
        rm -rf node_modules
        rm -f *.lock
        $command_to_run > /dev/null 2>&1
    fi

    echo '    '${tool} ${cache_text}

    # Run the given command [repeats] times
    for (( i = 1; i <= $repeats ; i++ ))
    do
        rm -rf node_modules
        rm -f *.lock

        # Clean cache
        if [ $clean_cache = 1 ]; then
            $command_to_clear_cache > /dev/null 2>&1
        fi

        # runs time function for the called script, output in a comma seperated
        # format output file specified with -o command and -a specifies append
        /usr/bin/time -f "%e %U %S" -o ${output_file} -a ${command_to_run} > /dev/null 2>&1

        # percentage completion
        p=$(( $i * 100 / $repeats))
        # indicator of progress
        l=$(seq -s "+" $i | sed 's/[0-9]//g')

        echo -ne '    '${l}' ('${p}'%) \r'
    done;

    echo -ne '\n'

    avg=$(awk '{ total += $1; count++ } END { print total/count }' $output_file)
    echo -n $avg' ' >> $avg_file

    cd $base_dir
}

show_results() {
    all_file=${output_folder}/avg.csv
    echo -n > $all_file

    for tool in "${tools[@]}"
    do
        avg_file_cc="${output_folder}/avg_${tool}_1.csv"
        avg_file="${output_folder}/avg_${tool}_0.csv"

        echo -n $tool'_with_empty_cache ' >> $all_file
        cat $avg_file_cc >> $all_file
        echo >> $all_file
        echo -n $tool'_with_all_cached ' >> $all_file
        cat $avg_file >> $all_file
        echo >> $all_file
    done

    echo ''
    echo ' ----------------------------------------------------------------------- '
    echo ' -------------------------- RESULTS (seconds) -------------------------- '
    echo ' ----------------------------------------------------------------------- '

    awk 'BEGIN {printf("| %24s | %12s | %12s | %12s | \n" , " ", "'${libraries[0]}'", "'${libraries[1]}'", "'${libraries[2]}'")}
        {printf("| %24s | %12.3f | %12.3f | %12.3f | \n", $1, $2, $3, $4)}' $all_file

    echo ' ----------------------------------------------------------------------- '
}

run_tests
show_results

echo $npm