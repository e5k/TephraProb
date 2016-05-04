function set_display
if isunix && ~ismac
    set(findobj('FontSize',10), 'FontSize',8);
end


