function [Pop]=Eliminate_Duplicates1(Pop)
fit=[cat(1,Pop.obj)];
[~, ind, ~]=unique(fit(:,1:end), 'rows', 'stable');
Pop=Pop(ind);
end % end function