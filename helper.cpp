/****************************************************************************
**
** qutIM - instant messenger
**
** Copyright © 2012 Ruslan Nigmatullin <euroelessar@yandex.ru>
**
*****************************************************************************
**
** $QUTIM_BEGIN_LICENSE$
** This program is free software: you can redistribute it and/or modify
** it under the terms of the GNU General Public License as published by
** the Free Software Foundation, either version 3 of the License, or
** (at your option) any later version.
**
** This program is distributed in the hope that it will be useful,
** but WITHOUT ANY WARRANTY; without even the implied warranty of
** MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
** See the GNU General Public License for more details.
**
** You should have received a copy of the GNU General Public License
** along with this program.  If not, see http://www.gnu.org/licenses/.
** $QUTIM_END_LICENSE$
**
****************************************************************************/

#include <cstdio>
#include <cstdlib>
#include <string>

char buf[1 << 16];
std::string content;

bool solve(const char *filePath)
{
	content.resize(0);
	FILE *file = fopen(filePath, "r");
	if (!file)
		return false;
	for (;;) {
		int len = fread(buf, 1, sizeof(buf), file);
		content.append(buf, len);
		if (len < sizeof(buf))
			break;
	}
	fclose(file);
	file = fopen(filePath, "w");
	static const std::string before = "<message>";
	static const std::string after = "<message utf8=\"true\">";
	size_t index = 0;
	size_t previous = 0;
	while ((index = content.find(before, previous)) != std::string::npos) {
		fwrite(&content[previous], index - previous, 1, file);
		fwrite(&after[0], after.length(), 1, file);
		previous = index + before.size();
	}
	fwrite(&content[previous], content.size() - previous, 1, file);
	fclose(file);
	return true;
}

int main(int argc, const char **argv)
{
	if (argc < 2) {
		fprintf(stderr, "%s needs at least one argument", argv[0]);
		return EXIT_FAILURE;
	}
	bool ok = true;
	for (int i = 1; i < argc; ++i)
		ok &= solve(argv[i]);
	return ok ? EXIT_SUCCESS : EXIT_FAILURE;
}
