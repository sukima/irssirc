# ulatrus.pl                             ru_RU.UTF-8 description
# to run it if it is here:               Запуск скрипта командой:
#
# /script load ~/.irssi/scripts/ulatrus.pl
#
# you can simply remove the script:      Выгружается скрипт командой:
# /script unload ulatrus
#
#######################################  ######################################
# Script work in UTF-8!                  Скрипт работает в UTF-8!
# 66 symbols are rusificated.            русифицирует 66 символов.
# russian characters in windows-1251     Русские буквы в Windows-1251
# are misinterpreted (by bitlbee) as     интерпретированные как ISO-8859-1
# ISO-8859-1 and are placed to accented  и помещённые в уникодовскую страницу
# european unicode page. This script     с европейскими акцентами. Эта
# returns them to russian page, keeping  программа возвращает их в русскую
# all other characters untouched.        страницу уникода, не трогая остальных.
#--------------------------------------  --------------------------------------
# you also can:                          Также вы можете:
# Turn conversion on/off separately:     вкл/выкл преобразование отдельно для:
#/set ulatrus_strip_in  <ON|off> -- входящих (по умолчанию вкл)
#/set ulatrus_strip_out <on|OFF> -- исходящих (по умолчанию выкл)
#
# Change tag for converted strings:      Изменить пометку преобразованного:
#/set ulatrus_tag_in  <string, default: [ulatrus]> входящих.
#/set ulatrus_tag_out <string, default: [ulatrus]> исходящих.
#
# Change table of conversion:           Изменить таблицу преобразования:
#/set ulatrus_lat <string> what         какие символы конвертировать
# default: "ÀÁÂÃÄÅ¨ÆÇÈÉÊËÌÍÎÏÐÑÒÓÔÕÖ×ØÙÚÛÜÝÞßàáâãäå¸æçèéêëìíîïðñòóôõö÷øùúûüýþÿ"
#/set ulatrus_rus <string> to what      в какие символы конвертировать
# default: "АБВГДЕЁЖЗИЙКЛМНОПРСТУФХЦЧШЩЪЫЬЭЮЯабвгдеёжзийклмнопрстуфхцчшщъыьэюя"
#
# Turn on/off debugging:                Вкл/выкл отладочную печать:
#/set ulatrus_debug <on|off> -- if you have a problem try to turn this on

use strict;
use vars qw($VERSION %IRSSI);

use utf8;
use Encode qw(encode decode is_utf8);
use encoding 'UTF-8', STDOUT => 'UTF-8', STDIN => 'UTF-8';

use Irssi;
$VERSION = '$Id: ulatrus.pl,v 1.00 2011/09/12 19:20:00 Sergej Qkowlew $';
%IRSSI = (
	authors     => 'Sergej Qkowlew',
	contact     => 'sergej_at_irssi_qkowlew1@qkowlew.org',
	name        => 'ulatrus',
	description => 'Script Changes latin1 ÀÁÂÃÄÅ¨Æ...þÿ to russian АБВГДЕЁ...юя UTF-8',
	license     => 'GPL',
);

my $stripped_out = 0;
my $stripped_in  = 0;

sub ulatrus_out {
	if(Irssi::settings_get_bool('ulatrus_strip_out') && !$stripped_out) {
		my $ulatrus_tag = Irssi::settings_get_str('ulatrus_tag_out');

		my $debug=Irssi::settings_get_bool('ulatrus_debug');
		
		my $ulatrus_lat = Irssi::settings_get_str('ulatrus_lat');
		my $ulatrus_rus = Irssi::settings_get_str('ulatrus_rus');
		if (length($ulatrus_lat) != length($ulatrus_rus)) {
			if ($debug) {
				Irssi::print("`$ulatrus_lat' and `$ulatrus_rus' hasn't same length");
			}
		}
		else {
			my $emitted_signal = Irssi::signal_get_emitted();
			my ($msg, $dummy1, $dummy2) = @_;

			if ($debug) {
				Irssi::print("signal emitted: $emitted_signal");
			}
			Encode::_utf8_on($msg);
			if ( $msg =~ /[$ulatrus_lat]/ ) {
				if ($debug) {
					Irssi::print("outgoing contains ulatrus: $msg");
				}
				eval "\$msg =~ tr/$ulatrus_lat/$ulatrus_rus/;";
				Encode::_utf8_on($msg);
				$msg = $msg . ' ' . $ulatrus_tag;
				Encode::_utf8_on($msg);
				$stripped_out=1;
				
				Irssi::signal_emit("$emitted_signal", $msg, $dummy1, $dummy2 );
				Irssi::signal_stop();
				$stripped_out=0;
			}
		}
	}
}

sub ulatrus_in {
	if(Irssi::settings_get_bool('ulatrus_strip_in') && !$stripped_in) {
		my $ulatrus_tag = Irssi::settings_get_str('ulatrus_tag_in');

		my $debug=Irssi::settings_get_bool('ulatrus_debug');
		
		my $ulatrus_lat = Irssi::settings_get_str('ulatrus_lat');
		my $ulatrus_rus = Irssi::settings_get_str('ulatrus_rus');
		if (length($ulatrus_lat) != length($ulatrus_rus)) {
			if ($debug) {
				Irssi::print("`$ulatrus_lat' and `$ulatrus_rus' hasn't same length");
			}
		}
		else {
			my $emitted_signal = Irssi::signal_get_emitted();

			my ($dummy0, $text, $dummy3, $dummy4, $dummy5) = @_;
			if ($debug) {
				Irssi::print("signal emitted: $emitted_signal");
			}
			Encode::_utf8_on($text);
			if ( $text =~ /[$ulatrus_lat]/ ) {
				if ($debug) {
					Irssi::print("incoming contains ulatrus: $text");
				}
				if ($debug) {
					Irssi::print("text=$text");
				}
				#no idea why w/o eval doesn't work:
				eval "\$text =~ tr/$ulatrus_lat/$ulatrus_rus/;";
				Encode::_utf8_on($text);
				$text = $text . ' ' . $ulatrus_tag;
				Encode::_utf8_on($text);
				$stripped_in=1;

				if ($debug) {
					Irssi::print("text=$text");
				}
				Irssi::signal_emit("$emitted_signal", $dummy0, $text, $dummy3, $dummy4, $dummy5 );
				Irssi::signal_stop();
				$stripped_in=0;
			}
		}
	}
}

#main():

#default settings /set ulatrus_in ON && ulatrus_out OFF:
Irssi::settings_add_bool('lookandfeel', 'ulatrus_strip_in', 1);
Irssi::settings_add_bool('lookandfeel', 'ulatrus_strip_out', 0);

#define the default tags for the filtered text:
Irssi::settings_add_str('lookandfeel', 'ulatrus_tag_in', '[ulatrus]');
Irssi::settings_add_str('lookandfeel', 'ulatrus_tag_out', '[ulatrus]');

#define which chars will be changed:
Irssi::settings_add_str('lookandfeel', 'ulatrus_lat', "ÀÁÂÃÄÅ¨ÆÇÈÉÊËÌÍÎÏÐÑÒÓÔÕÖ×ØÙÚÛÜÝÞßàáâãäå¸æçèéêëìíîïðñòóôõö÷øùúûüýþÿ");
Irssi::settings_add_str('lookandfeel', 'ulatrus_rus', "АБВГДЕЁЖЗИЙКЛМНОПРСТУФХЦЧШЩЪЫЬЭЮЯабвгдеёжзийклмнопрстуфхцчшщъыьэюя");

#define wheather debug or not (default OFF):
Irssi::settings_add_bool('lookandfeel', 'ulatrus_debug', 0);

#filters:
#incoming filters:
Irssi::signal_add_first('server event', 'ulatrus_in');

#output filters:
Irssi::signal_add_first('send command', 'ulatrus_out');
#Irssi::signal_add_first('message own_public', 'ulatrus_out');
#Irssi::signal_add_first('message own_private', 'ulatrus_out');

#startup info:
Irssi::print("latin1 to cp1251 unicode stripper by Qkowlew based on accent.pl by Tamas SZERB toma\@rulez.org");
Irssi::print("Version: $VERSION");
