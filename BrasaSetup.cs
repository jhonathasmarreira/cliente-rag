using System;
using System.Drawing;
using System.IO;
using System.Text;
using System.Windows.Forms;
using Microsoft.Win32;

static class Program {
  [STAThread]
  static void Main() {
    Application.EnableVisualStyles();
    Application.SetCompatibleTextRenderingDefault(false);
    Application.Run(new SetupForm());
  }
}

sealed class SetupForm : Form {
  static readonly string[] Resolutions = {
    "640 x 480",
    "800 x 600",
    "1024 x 768",
    "1152 x 864",
    "1280 x 720",
    "1280 x 768",
    "1280 x 800",
    "1280 x 960",
    "1280 x 1024",
    "1360 x 768",
    "1366 x 768",
    "1440 x 900",
    "1600 x 900",
    "1600 x 1200",
    "1680 x 1050",
    "1920 x 1080",
    "1920 x 1200",
    "2560 x 1440",
  };

  readonly ComboBox _reso;
  readonly ComboBox _bpp;
  readonly CheckBox _full;
  readonly CheckBox _fog;
  readonly TrackBar _sprite;
  readonly TrackBar _texture;
  readonly string _dir;

  public SetupForm() {
    _dir = AppDomain.CurrentDomain.BaseDirectory.TrimEnd('\\', '/') + "\\";

    Text = "BrasaRO Setup";
    FormBorderStyle = FormBorderStyle.FixedDialog;
    MaximizeBox = false;
    MinimizeBox = false;
    StartPosition = FormStartPosition.CenterScreen;
    ClientSize = new Size(420, 360);
    BackColor = Color.FromArgb(240, 240, 240);
    Font = new Font("Segoe UI", 9f);

    var title = new Label {
      Text = "BrasaRO \u2014 Configura\u00e7\u00e3o de V\u00eddeo",
      Font = new Font("Segoe UI Semibold", 11f),
      AutoSize = true,
      Location = new Point(16, 14),
    };
    var hint = new Label {
      Text = "Este Setup grava no registry do Windows 11 (o Setup oficial n\u00e3o lista v\u00eddeo).",
      AutoSize = false,
      Size = new Size(388, 32),
      Location = new Point(16, 42),
      ForeColor = Color.FromArgb(80, 80, 80),
    };

    Controls.Add(title);
    Controls.Add(hint);
    Controls.Add(MakeLabel("Resolu\u00e7\u00e3o", 16, 88));
    _reso = new ComboBox {
      DropDownStyle = ComboBoxStyle.DropDownList,
      Location = new Point(140, 84),
      Width = 240,
    };
    _reso.Items.AddRange(Resolutions);
    Controls.Add(_reso);

    Controls.Add(MakeLabel("Cores", 16, 124));
    _bpp = new ComboBox {
      DropDownStyle = ComboBoxStyle.DropDownList,
      Location = new Point(140, 120),
      Width = 120,
    };
    _bpp.Items.AddRange(new object[] { "16 bit", "32 bit" });
    Controls.Add(_bpp);

    _full = new CheckBox {
      Text = "Tela cheia (Full Screen)",
      Location = new Point(140, 158),
      AutoSize = true,
    };
    Controls.Add(_full);

    _fog = new CheckBox {
      Text = "Neblina (Fog)",
      Location = new Point(140, 186),
      AutoSize = true,
    };
    Controls.Add(_fog);

    Controls.Add(MakeLabel("Detalhe sprite", 16, 228));
    _sprite = new TrackBar {
      Location = new Point(140, 220),
      Width = 240,
      Minimum = 0,
      Maximum = 4,
      TickStyle = TickStyle.BottomRight,
      Value = 2,
    };
    Controls.Add(_sprite);

    Controls.Add(MakeLabel("Detalhe textura", 16, 268));
    _texture = new TrackBar {
      Location = new Point(140, 260),
      Width = 240,
      Minimum = 0,
      Maximum = 4,
      TickStyle = TickStyle.BottomRight,
      Value = 2,
    };
    Controls.Add(_texture);

    var ok = new Button {
      Text = "OK",
      DialogResult = DialogResult.None,
      Location = new Point(220, 312),
      Width = 80,
    };
    ok.Click += (_, __) => { Save(); Close(); };

    var cancel = new Button {
      Text = "Cancelar",
      DialogResult = DialogResult.Cancel,
      Location = new Point(310, 312),
      Width = 80,
    };
    cancel.Click += (_, __) => Close();

    AcceptButton = ok;
    CancelButton = cancel;
    Controls.Add(ok);
    Controls.Add(cancel);

    LoadCurrent();
  }

  static Label MakeLabel(string text, int x, int y) {
    return new Label {
      Text = text,
      AutoSize = true,
      Location = new Point(x, y),
    };
  }

  void LoadCurrent() {
    int w = 1024, h = 768, bpp = 32, full = 0, fog = 0, sprite = 2, texture = 2;
    try {
      using (var k = Registry.CurrentUser.OpenSubKey(@"Software\Gravity Soft\Ragnarok")) {
        if (k != null) {
          w = ToInt(k.GetValue("WIDTH"), w);
          h = ToInt(k.GetValue("HEIGHT"), h);
          bpp = ToInt(k.GetValue("BITPERPIXEL"), bpp);
          full = ToInt(k.GetValue("ISFULLSCREENMODE"), full);
          fog = ToInt(k.GetValue("FOG"), fog);
          sprite = ToInt(k.GetValue("SPRITEMODE"), sprite);
          texture = ToInt(k.GetValue("TEXTUREMODE"), texture);
        }
      }
    } catch { }

    string want = w + " x " + h;
    int idx = _reso.Items.IndexOf(want);
    if (idx < 0) {
      _reso.Items.Insert(0, want);
      idx = 0;
    }
    _reso.SelectedIndex = idx;
    _bpp.SelectedIndex = bpp <= 16 ? 0 : 1;
    _full.Checked = full != 0;
    _fog.Checked = fog != 0;
    _sprite.Value = Clamp(sprite, 0, 4);
    _texture.Value = Clamp(texture, 0, 4);
  }

  void Save() {
    int w, h;
    ParseReso(_reso.SelectedItem.ToString(), out w, out h);
    int bpp = _bpp.SelectedIndex == 0 ? 16 : 32;
    int full = _full.Checked ? 1 : 0;
    int fog = _fog.Checked ? 1 : 0;
    int sprite = _sprite.Value;
    int texture = _texture.Value;

    WriteGravitySoft(w, h, bpp, full, fog, sprite, texture);
    WriteRagnarokOnline(w, h, bpp, full);
    WriteOptionInfo(w, h, full);
    WriteDgVoodooHint(full);

    MessageBox.Show(
      "Salvo.\n\nResolu\u00e7\u00e3o: " + w + "x" + h +
      "\nModo: " + (full != 0 ? "Tela cheia" : "Janela") +
      "\n\nFeche e abra o BrasaRO.exe para aplicar.",
      "BrasaRO Setup",
      MessageBoxButtons.OK,
      MessageBoxIcon.Information);
  }

  void WriteGravitySoft(int w, int h, int bpp, int full, int fog, int sprite, int texture) {
    using (var k = Registry.CurrentUser.CreateSubKey(@"Software\Gravity Soft\Ragnarok")) {
      k.SetValue("WIDTH", w, RegistryValueKind.DWord);
      k.SetValue("HEIGHT", h, RegistryValueKind.DWord);
      k.SetValue("BITPERPIXEL", bpp, RegistryValueKind.DWord);
      k.SetValue("ISFULLSCREENMODE", full, RegistryValueKind.DWord);
      k.SetValue("FOG", fog, RegistryValueKind.DWord);
      k.SetValue("SPRITEMODE", sprite, RegistryValueKind.DWord);
      k.SetValue("TEXTUREMODE", texture, RegistryValueKind.DWord);
      k.SetValue("ISVOODOO", 0, RegistryValueKind.DWord);
      k.SetValue("ISLIGHTMAP", 1, RegistryValueKind.DWord);
      k.SetValue("SOUNDMODE", 1, RegistryValueKind.DWord);
      k.SetValue("DEVICECNT", 0, RegistryValueKind.DWord);
      k.SetValue("MODECNT", 10, RegistryValueKind.DWord);
      k.SetValue("CHECKSAVE", 1, RegistryValueKind.DWord);
      k.SetValue("DEVICENAME", "dgVoodoo TnL HAL", RegistryValueKind.String);
      k.SetValue("GUIDDEVICE", new byte[] {
        0xE0,0x3D,0xE6,0x84,0xAA,0x46,0xCF,0x11,0x81,0x6F,0x00,0x00,0xC0,0x20,0x15,0x6E
      }, RegistryValueKind.Binary);
      k.SetValue("GUIDDRIVER", new byte[16], RegistryValueKind.Binary);
    }
  }

  void WriteRagnarokOnline(int w, int h, int bpp, int full) {
    using (var k = Registry.CurrentUser.CreateSubKey(@"Software\Gravity\RagnarokOnline")) {
      k.SetValue("WIDTH", w, RegistryValueKind.DWord);
      k.SetValue("HEIGHT", h, RegistryValueKind.DWord);
      k.SetValue("BITPERPIXEL", bpp, RegistryValueKind.DWord);
      k.SetValue("ISFULLSCREENMODE", full, RegistryValueKind.DWord);
      k.SetValue("RagPath", _dir, RegistryValueKind.String);
    }
  }

  void WriteOptionInfo(int w, int h, int full) {
    string path = Path.Combine(_dir, "SaveData", "OptionInfo.lua");
    try {
      Directory.CreateDirectory(Path.GetDirectoryName(path));
      var sb = new StringBuilder();
      if (File.Exists(path)) {
        foreach (string line in File.ReadAllLines(path, Encoding.Default)) {
          string t = line.Trim();
          if (t.StartsWith("CmdOnOffList[\"/window\"]") ||
              t.StartsWith("OptionInfoList[\"WIDTH\"]") ||
              t.StartsWith("OptionInfoList[\"HEIGHT\"]") ||
              t.StartsWith("OptionInfoList[\"ISFULLSCREENMODE\"]") ||
              t.StartsWith("OptionInfoList[\"BITPERPIXEL\"]"))
            continue;
          sb.AppendLine(line);
        }
      } else {
        sb.AppendLine("CmdOnOffList[\"/fog\"] = 0");
        sb.AppendLine("CmdOnOffList[\"/camera\"] = 1");
        sb.AppendLine("CmdOnOffList[\"/effect\"] = 1");
        sb.AppendLine("CmdOnOffList[\"/bgm\"] = 1");
        sb.AppendLine("CmdOnOffList[\"/sound\"] = 1");
        sb.AppendLine("CmdOnOffList[\"/showname\"] = 1");
      }
      sb.AppendLine("CmdOnOffList[\"/window\"] = " + (full != 0 ? "0" : "1"));
      sb.AppendLine("OptionInfoList[\"WIDTH\"] = " + w);
      sb.AppendLine("OptionInfoList[\"HEIGHT\"] = " + h);
      sb.AppendLine("OptionInfoList[\"BITPERPIXEL\"] = 32");
      sb.AppendLine("OptionInfoList[\"ISFULLSCREENMODE\"] = " + full);
      File.WriteAllText(path, sb.ToString(), Encoding.GetEncoding(1252));
    } catch { }
  }

  void WriteDgVoodooHint(int full) {
    string conf = Path.Combine(_dir, "dgVoodoo.conf");
    try {
      string body;
      if (File.Exists(conf)) body = File.ReadAllText(conf);
      else body = "[General]\r\nOutputAPI = d3d11_fl11_0\r\n[DirectX]\r\nVRAM = 2048\r\ndgVoodooWatermark = false\r\n";

      if (body.IndexOf("AppControlledScreenMode", StringComparison.OrdinalIgnoreCase) >= 0)
        body = System.Text.RegularExpressions.Regex.Replace(
          body, @"AppControlledScreenMode\s*=\s*\w+", "AppControlledScreenMode = true",
          System.Text.RegularExpressions.RegexOptions.IgnoreCase);
      else if (body.IndexOf("[DirectX]", StringComparison.OrdinalIgnoreCase) >= 0)
        body = body.Replace("[DirectX]", "[DirectX]\r\nAppControlledScreenMode = true");
      else
        body += "\r\n[DirectX]\r\nAppControlledScreenMode = true\r\n";

      if (body.IndexOf("dgVoodooWatermark", StringComparison.OrdinalIgnoreCase) < 0)
        body += "dgVoodooWatermark = false\r\n";

      File.WriteAllText(conf, body, Encoding.ASCII);
    } catch { }
  }

  static void ParseReso(string s, out int w, out int h) {
    string[] p = s.Split(new[] { 'x', 'X', '*' }, StringSplitOptions.RemoveEmptyEntries);
    w = int.Parse(p[0].Trim());
    h = int.Parse(p[1].Trim());
  }

  static int ToInt(object v, int def) {
    if (v == null) return def;
    try { return Convert.ToInt32(v); } catch { return def; }
  }

  static int Clamp(int v, int min, int max) {
    if (v < min) return min;
    if (v > max) return max;
    return v;
  }
}
