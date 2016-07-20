function colOrd = colorPalette(name)
%colorPalette
%   colOrd = colorPalette(name) returns an RGB matrix to use when setting
%   the default color order in plots
%   source for the color palettes:
%       http://tableaufriction.blogspot.ro/2012/11/finally-you-can-use-tableau-data-colors.html
%
%   JAC - Aug 29 2015

switch name
    case 'blind'
        colOrd = [...
            0 107 164
            255 128 14
            171 171 171
            89 89 89
            95 158 209
            200 82 0
            137 137 137
            162 200 236
            255 188 121
            207 207 207
            ]/255;
    case 'gray'
        colOrd = [...
            96 99 106
            165 172 175
            65 68 81
            143 135 130
            207 207 207
            ]/255;
    case 'tableau10M'
        colOrd = [...
            114 158 206
            255 158 74
            103 191 92
            237 102 93
            173 139 201
            168 120 110
            237 151 202
            162 162 162
            205 204 93
            109 204 218
            ]/255;
    case 'tableau10L'
        colOrd = [...
            174 199 232
            255 187 120
            152 223 138
            255 152 150
            197 176 213
            196 156 148
            247 182 210
            199 199 199
            219 219 141
            158 218 229
            ]/255;
    case 'tableau20'
        colOrd = [...
            255 187 120
            255 127 14
            174 199 232
            44 160 44
            31 119 180
            255 152 150
            214 39 40
            197 176 213
            152 223 138
            148 103 189
            247 182 210
            227 119 194
            196 156 148
            140 86 75
            127 127 127
            219 219 141
            199 199 199
            188 189 34
            158 218 229
            23 190 207
            ]/255;
    case 'striking'
        colOrd = [...
            0 0 1
            1 1 0
            1 131/255 0 % orange
            1 0 1
            0 1 1
            1 0 0
            0 1 0
            ];
    otherwise % default is tableau10
        colOrd = [...
            31 119 180
            255 127 14
            44 160 44
            214 39 40
            148 103 189
            140 86 75
            227 119 194
            127 127 127
            188 189 34
            23 190 207
            ]/255;
end