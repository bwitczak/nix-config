#
#  System Themes
#

let
  schemes = {
    default = {
      scheme = "Fantasy Night";
      hex = {
        bg = "0d1117";        # Deep dark blue-black like the night sky
        fg = "e5d0a9";        # Warm cream/parchment like firelight
        red = "d65d4e";       # Muted red like embers
        orange = "f58b3c";    # Bright orange like the campfire
        yellow = "e5c07b";    # Golden yellow like firelight
        green = "4c8052";     # Forest green like the trees
        cyan = "56b6c2";      # Cool cyan like moonlight
        blue = "6aa8d6";      # Steel blue like the night sky
        purple = "b294bb";    # Muted purple like twilight
        white = "dcdcdc";     # Soft white like moonlight
        black = "0b0910";     # Very dark purple-black
        gray = "5c6370";      # Medium gray like shadows
        highlight = "f58b3c"; # Orange highlight like fire
        comment = "7f848e";   # Muted gray for comments
        active = "f58b3c";    # Fire orange for active elements
        inactive = "2a2d3a";  # Dark gray for inactive elements
        text = "b8a082";      # Warm beige for secondary text
      };
      rgb = {
        bg = "13, 17, 23";        # Deep dark blue-black
        fg = "229, 208, 169";     # Warm cream/parchment
        red = "214, 93, 78";      # Muted red like embers
        orange = "245, 139, 60";  # Bright orange like campfire
        yellow = "229, 192, 123"; # Golden yellow
        green = "76, 128, 82";    # Forest green
        cyan = "86, 181, 194";    # Cool cyan
        blue = "106, 168, 214";   # Steel blue
        purple = "178, 148, 187"; # Muted purple
        white = "220, 220, 220";  # Soft white
        black = "11, 9, 16";      # Very dark purple-black
        gray = "92, 99, 112";     # Medium gray
        highlight = "245, 139, 60"; # Orange highlight
        comment = "127, 132, 142";  # Muted gray
        active = "245, 139, 60";    # Fire orange
        inactive = "42, 45, 58";    # Dark gray
        text = "184, 160, 130";     # Warm beige
      };
    };

    onedark = {
      scheme = "One Dark Pro";
      hex = {
        bg = "111111"; # 283c34
        fg = "abb2bf";
        red = "e06c75";
        orange = "d19a66";
        yellow = "e5c07b";
        green = "98c379";
        cyan = "56b6c2";
        blue = "61afef";
        purple = "c678dd";
        white = "abb2bf";
        black = "282c34";
        gray = "5c6370";
        highlight = "e2be7d";
        comment = "7f848e";
        active = "005577";
        inactive = "333333";
        text = "999999";
      };
      rgb = {
        bg = "17, 17, 17";
        fg = "171, 178, 191";
        red = "224, 108, 118";
        orange = "209, 154, 102";
        yellow = "229, 192, 123";
        green = "152, 195, 121";
        cyan = "86, 181, 194";
        blue = "97, 175, 223";
        purple = "197, 120, 221";
        white = "171, 178, 191";
        black = "40, 44, 52";
        gray = "92, 99, 112";
        highlight = "226, 191, 125";
        comment = "127, 132, 142";
        active = "0, 85, 119";
        inactive = "51, 51, 51";
        text = "153, 153, 153";
      };
    };

    doom = {
      scheme    = "Doom One Dark";
      black     = "000000";
      red       = "ff6c6b";
      orange    = "da8548";
      yellow    = "ecbe7b";
      green     = "95be65";
      teal      = "4db5bd";
      blue      = "6eaafb";
      dark-blue = "2257a0";
      magenta   = "c678dd";
      violet    = "a9a1e1";
      cyan      = "6cdcf7";
      dark-cyan = "5699af";
      emphasis  = "50536b";
      text      = "dfdfdf";
      text-alt  = "b2b2b2";
      fg        = "abb2bf";
      bg        = "282c34";
    };

    dracula = {
      scheme = "Dracula";
      base00 = "282936"; #background
      base01 = "3a3c4e";
      base02 = "4d4f68";
      base03 = "626483";
      base04 = "62d6e8";
      base05 = "e9e9f4"; #foreground
      base06 = "f1f2f8";
      base07 = "f7f7fb";
      base08 = "ea51b2";
      base09 = "b45bcf";
      base0A = "00f769";
      base0B = "ebff87";
      base0C = "a1efe4";
      base0D = "62d6e8";
      base0E = "b45bcf";
      base0F = "00f769";
    };
  };
in
{
  # Export scheme for compatibility
  scheme = schemes;
  
  # Export default colors for easy access
  colors = {
    inherit (schemes.default) hex rgb;
  };
}
