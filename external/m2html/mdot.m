function mdot(mmat, dotfile,f)
%MDOT - Export a dependency graph into DOT language
%  MDOT(MMAT, DOTFILE) loads a .mat file generated by M2HTML using option
%  ('save','on') and writes an ascii file using the DOT language that can
%  be drawn using <dot> or <neato> .
%  MDOT(MMAT, DOTFILE,F) builds the graph containing M-file F and its
%  neighbors only.
%  See the folowing page for more details:
%  <http://www.research.att.com/sw/tools/graphviz/>
%
%  Example:
%    mdot('m2html.mat','m2html.dot');
%    !dot -Tps m2html.dot -o m2html.ps
%    !neato -Tps m2html.dot -o m2html.ps
%
%  See also M2HTML

%  Copyright (C) 2003 Guillaume Flandin <Guillaume@artefact.tk>
%  $Revision: 1.0 $Date: 2003/29/04 17:33:43 $

error(nargchk(2,3,nargin));

if ischar(mmat)
	load(mmat);
elseif iscell(mmat)
	hrefs  = mmat{1};
	names  = mmat{2};
	options = mmat{3};
	if nargin == 3, mfiles = mmat{4}; end
else
	error('[mdot] Invalid argument: mmat.');
end

if 1
    URLnames=names;
else
    %relative path needed for URL of mfile documentation
    mfiles = mmat{4};
    URLnames=cell(size(hrefs,1),1);
    for i=1:size(hrefs,1)
        if 0
            rem=mfiles{i};
            while ~isempty(rem)
                [str,rem]=strtok(rem,'/');
            end
            URLnames{i}=str(1:end-2);
        else
            URLnames{i}=mfiles{i}(length(options.mFiles{1})+2:end-2);
        end
    end
    pause(eps)
end

fid = fopen(dotfile,'w');
if fid == -1, error(sprintf('[mdot] Cannot open %s.',dotfile)); end

fprintf(fid,'/* Created by mdot for Matlab */\n');
fprintf(fid,'digraph m2html {\n');

if nargin == 2
	for i=1:size(hrefs,1)
		n = find(hrefs(i,:) == 1);
		m{i} = n;
		for j=1:length(n)
			fprintf(fid,['  ' names{i} ' -> ' names{n(j)} ';\n']);
		end
	end
	%m = unique([m{:}]);
	fprintf(fid,'\n');
	for i=1:size(hrefs,1)
		fprintf(fid,['  ' names{i} ' [URL="' URLnames{i} options.extension '"];\n']);
	end
else
	i = find(strcmp(f,mfiles));
	if length(i) ~= 1
		error(sprintf('[mdot] Cannot find %s.',f));
	end
	n = find(hrefs(i,:) == 1);
	for j=1:length(n)
		fprintf(fid,['  ' names{i} ' -> ' names{n(j)} ';\n']);
	end
	m = find(hrefs(:,i) == 1);
	for j=1:length(m)
		if n(j) ~= i
			fprintf(fid,['  ' names{m(j)} ' -> ' names{i} ';\n']);
		end
	end
	n = unique([n(:)' m(:)']);
	fprintf(fid,'\n');
	for i=1:length(n)
		fprintf(fid,['  ' names{n(i)} ' [URL="' URLnames{n(i)} options.extension '"];\n']);
	end
end

fprintf(fid,'}');

fid = fclose(fid);
if fid == -1, error(sprintf('[mdot] Cannot close %s.',dotfile)); end
