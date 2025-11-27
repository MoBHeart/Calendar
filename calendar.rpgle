**free

ctl-opt nomain;

/copy qpttsrc,calendar

dcl-proc ClcWkdNbr                             export;
  dcl-pi *n                                    zoned(1);
    p_datum                                    date;
  end-pi;

  dcl-s  date_Nulldatum                        date;
  dcl-s  num_difference                        zoned(3);


  date_Nulldatum = %date('0001-01-01');


  num_difference = %rem(%diff(p_datum: %date(%char(date_Nulldatum) : *ISO):*days):7) + 1;
  return num_difference;

end-proc;

dcl-proc ClcWkdChr                             export;
  dcl-pi *n                                    char(2);
  p_num_tag                                    zoned(1);
  end-pi;

  dcl-ds Tag_DS qualified;
    *n                                         char(14) inz('MODIMIDOFRSASO');
    MOSO                                       char(2) pos(1) dim(7);
  end-ds;

  dcl-s p_char_tag                             char(2);

  p_char_tag = Tag_DS.MOSO(p_num_tag);
  return p_char_tag;

end-proc;

dcl-proc ClcWoY                                export;
  dcl-pi *n                                    zoned(2);
  p_datum                                      date;
  end-pi;

  dcl-s date_4_1                               date;
  dcl-s date_DO                                date;
  dcl-s date_MOKW1                             date;
  dcl-s num_MODiff                             zoned(1);
  dcl-s num_4_1                                zoned(1);
  dcl-s num_DODiff                             zoned(2);
  dcl-s num_WT                                 zoned(1);
  dcl-s num_year                               zoned(4);
  dcl-s num_KW                                 zoned(2);
  dcl-s num_difference                         zoned(4);

  num_WT = CLCWKDNBR(p_datum);
  num_DODiff = 4 - num_WT;
  date_DO = p_datum + %days(num_DODiff);

  num_year = %subdt(date_DO : *years);
  date_4_1 = %date(%concat('' : %char(num_year) : '-01-04') : *ISO);
  num_4_1 = CLCWKDNBR(date_4_1);
  num_MODiff = num_4_1 - 1;
  date_MOKW1 = date_4_1 - %days(num_MODiff);

  num_difference = %diff(p_datum : date_MOKW1 : *days);
  num_KW = %div(num_difference : 7) + 1;
  return num_KW;

end-proc;

dcl-proc HldName                              export;
  dcl-pi *n                                   char(50);
    p_datum                                   date;
  end-pi;

  dcl-c M                                     const(24);
  dcl-c N                                     const(5);
  dcl-s a                                     zoned(2);
  dcl-s b                                     zoned(2);
  dcl-s c                                     zoned(2);
  dcl-s d                                     zoned(2);
  dcl-s e                                     zoned(2);
  dcl-s year                                  zoned(4);
  dcl-s num_OS                                zoned(2);
  dcl-s leap                                  zoned(1);
  dcl-s num_OSmonth                           zoned(1);
  dcl-s date_OS                               date;
  dcl-s Pfingstsonntag                        date;

  year = %subdt(p_datum : *years);

  a = %rem(year : 19);
  b = %rem(year : 4);
  c = %rem(year : 7);
  d = %rem((19 * a + M) : 30);
  e = %rem((2 * b + 4 * c + 6 * d + N) : 7);

  num_OS = 22 + d + e;
  if (num_OS > 31);
    num_OS = d + e - 9;
    leap += 1;
  endif;
  num_OSmonth = 3 + leap;

  date_OS = %date(%concat('' : %char(year) : '-01-01') : *ISO);
  date_OS = date_OS + %months(num_OSmonth - 1);
  date_OS = date_OS + %days(num_OS - 1);

  Pfingstsonntag = date_OS + %days(49);

  select;
    when ((%subdt(p_datum : *days) = 1) AND (%subdt(p_datum : *months) = 1));
      return 'Neujahr';

    when ((%subdt(p_datum : *days) = 6) AND (%subdt(p_datum : *months) = 1));
      return 'Heilige Drei Könige';

    when ((%subdt(p_datum : *days) = num_OS) AND (%subdt(p_datum : *months) = 3 + leap));
      return 'Ostersonntag';

    when ((%subdt(p_datum : *days) = num_OS + 1) AND (%subdt(p_datum : *months) = 3 + leap));
      return 'Ostermontag';

    when ((%subdt(p_datum : *days) = 1) AND (%subdt(p_datum : *months) = 5));
      return 'Staatsfeiertag 1.Mai';

    when p_datum = Pfingstsonntag - %days(48);
      return 'Rosenmontag';

    when p_datum = Pfingstsonntag - %days(2);
      return 'Karfreitag';

    when p_datum = Pfingstsonntag;
      return 'Pfingstsonntag';

    when p_datum = Pfingstsonntag + %days(1);
      return 'Pfingstmontag';

    when p_datum = Pfingstsonntag + %days(60);
      return 'Fronleichnam';

    when ((%subdt(p_datum : *days) = 15) AND (%subdt(p_datum : *months) = 8));
      return 'Mariä Himmelfahrt';

    when ((%subdt(p_datum : *days) = 26) AND (%subdt(p_datum : *months) = 10));
      return 'Nationalfeiertag';

    when ((%subdt(p_datum : *days) = 1) AND (%subdt(p_datum : *months) = 11));
      return 'Allerheiligen';

    when ((%subdt(p_datum : *days) = 8) AND (%subdt(p_datum : *months) = 12));
      return 'Mariä Empfängnis';

    when ((%subdt(p_datum : *days) = 24) AND (%subdt(p_datum : *months) = 12));
      return 'Weihnachten';

    when ((%subdt(p_datum : *days) = 25) AND (%subdt(p_datum : *months) = 12));
      return 'Stefanitag';

    when ((%subdt(p_datum : *days) = 31) AND (%subdt(p_datum : *months) = 12));
      return 'Silvester';

    other;
      return ('');
  endsl;

end-proc;

dcl-proc DatHld                               export;
  dcl-pi *n                                   zoned(1);
    p_datum                                   date;
  end-pi;

  if (HLDNAME(p_datum) <> '');
    return 1;
  else;
    return 0;
  endif;
end-proc;

dcl-proc IsStrDat                             export;
  dcl-pi *n                                   ind;
    p_date                                    char(8) value;
  end-pi;

  monitor;

  Test(DE) *ISO0 p_date;
  if %error();
    return *off;
  endif;
  return *on;

  on-error;
    return *off;
  endmon;

end-proc;
