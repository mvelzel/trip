module.exports = {
  mode: 'jit',
  purge: [
    "../lib/**/*.eex",
    "../lib/**/*.leex",
    "../lib/**/*_view.ex",
    "../assets/**/*.js",
    "../lib/**/views/*.ex"
  ],
  plugins: [
    require('@tailwindcss/forms'),
    require('@tailwindcss/typography')
  ],
  theme: {
    extend: {
      colors: {
        "t-red": "#F23054",
        "tr-red": "#F23054",
        "t-darkRed": "#BF263A",
        "tr-darkRed": "#BF263A",
        "t-blue": "#056CF2",
        "t-darkBlue": "#0455BF",
        "t-darkerBlue": "#033E8C",
        "t-green": "#22F2A6",
        "tr-green": "#22F2A6",
        "t-darkGreen": "#05734C",
        "t-black": "#222222"
      }
    },
    fontFamily: {
      'sans': 'Clash Grotesk, sans-serif'
    }
  }
}
