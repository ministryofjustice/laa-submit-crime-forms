class EthnicGroups < ValueObject
  VALUES = [
    OTHER = new(:'00_other'),
    WHITE_BRITISH = new(:'01_white_british'),
    WHITE_IRISH = new(:'02_white_irish'),
    BLACK_OR_BLACK_BRITISH_AFRICAN = new(:'03_black_or_black_british_african'),
    BLACK_OR_BLACK_BRITISH_CARIBBEAN = new(:'04_black_or_black_british_caribbean'),
    BLACK_OR_BLACK_BRITISH_OTHER = new(:'05_black_or_black_british_other'),
    ASIAN_OR_ASIAN_BRITISH_INDIAN = new(:'06_asian_or_asian_british_indian'),
    ASIAN_OR_ASIAN_BRITISH_PAKISTANI = new(:'07_asian_or_asian_british_pakistani'),
    ASIAN_OR_ASIAN_BRITISH_BANGLADESHI = new(:'08_asian_or_asian_british_bangladeshi'),
    CHINESE = new(:'09_chinese'),
    MIXED_WHITE_BLACK_CARIBBEAN = new(:'10_mixed_white_black_caribbean'),
    MIXED_WHITE_BLACK_AFRICAN = new(:'11_mixed_white_black_african'),
    MIXED_WHITE_ASIAN = new(:'12_mixed_white_asian'),
    MIXED_OTHER = new(:'13_mixed_other'),
    WHITE_OTHER = new(:'14_white_other'),
    ASIAN_OR_ASIAN_BRITISH_OTHER = new(:'15_asian_or_asian_british_other'),
    UNKNOWN = new(:'99_unknown'),
  ].freeze
end
