{
  addressable = {
    dependencies = ["public_suffix"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0cl2qpvwiffym62z991ynks7imsm87qmgxf0yfsmlwzkgi9qcaa6";
      type = "gem";
    };
    version = "2.8.7";
  };
  faraday = {
    dependencies = ["faraday-net_http" "logger"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "104s7n9505488p923cs0pl3jlgn4naam28clkm2885hrysizpjbb";
      type = "gem";
    };
    version = "2.10.1";
  };
  faraday-net_http = {
    dependencies = ["net-http"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0f49frpfdr8czwm2mjkfny4pini6fy49b6hamw4jrppl4vsg14ys";
      type = "gem";
    };
    version = "3.1.1";
  };
  logger = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0gpg8gzi0xwymw4aaq2iafcbx31i3xzkg3fb30mdxn1d4qhc3dqa";
      type = "gem";
    };
    version = "1.6.0";
  };
  net-http = {
    dependencies = ["uri"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "10n2n9aq00ih8v881af88l1zyrqgs5cl3njdw8argjwbl5ggqvm9";
      type = "gem";
    };
    version = "0.4.1";
  };
  octokit = {
    dependencies = ["faraday" "sawyer"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "15g4kyag6gmxxq6d03472h7srm3imlsks1wg6nac7hl3mb1b5vs8";
      type = "gem";
    };
    version = "5.6.1";
  };
  public_suffix = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0vqcw3iwby3yc6avs1vb3gfd0vcp2v7q310665dvxfswmcf4xm31";
      type = "gem";
    };
    version = "6.0.1";
  };
  sawyer = {
    dependencies = ["addressable" "faraday"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1jks1qjbmqm8f9kvwa81vqj39avaj9wdnzc531xm29a55bb74fps";
      type = "gem";
    };
    version = "0.9.2";
  };
  uri = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "094gk72ckazf495qc76gk09b5i318d5l9m7bicg2wxlrjcm3qm96";
      type = "gem";
    };
    version = "0.13.0";
  };
}
