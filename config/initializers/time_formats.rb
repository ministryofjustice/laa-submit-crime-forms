# Add consistent default time formats for use by presentation layer
# `my_date.to_fs(:stamp)`
# instead of
# `my_date.strftime('%d %B %Y')`
#
Date::DATE_FORMATS[:stamp] = '%d %B %Y' # DD MONTH YYYY
Time::DATE_FORMATS[:stamp] = '%d %B %Y' # DD MONTH YYYY
