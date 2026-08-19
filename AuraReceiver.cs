using System;
using System.Collections.Generic;
using System.Threading;
using AuraServiceLib;

internal static class AuraReceiver
{
    public static int Main()
    {
        try
        {
            IAuraSdk sdk = new AuraSdk();
            var devices = new List<IAuraSyncDevice>();
            foreach (IAuraSyncDevice d in sdk.Enumerate(0))
                if ((d.Name ?? "").IndexOf("ENE_RGB_AURA", StringComparison.OrdinalIgnoreCase) >= 0)
                    devices.Add(d);
            if (devices.Count == 0) return 3;
            sdk.SwitchMode();
            Console.Error.WriteLine("ARES devices: " + devices.Count);
            string latest = null;
            bool ended = false;
            var signal = new AutoResetEvent(false);
            var reader = new Thread(() =>
            {
                string incoming;
                while ((incoming = Console.ReadLine()) != null) { latest = incoming; signal.Set(); }
                ended = true; signal.Set();
            });
            reader.IsBackground = true; reader.Start();
            while (!ended)
            {
                signal.WaitOne();
                var line = latest;
                if (line == null) continue;
                var p = line.Split(' ');
                if (p.Length != 3) continue;
                byte r, g, b;
                if (!byte.TryParse(p[0], out r) || !byte.TryParse(p[1], out g) || !byte.TryParse(p[2], out b)) continue;
                foreach (var d in devices)
                {
                    foreach (IAuraRgbLight led in d.Lights) { led.Red = r; led.Green = g; led.Blue = b; }
                    d.Apply();
                }
            }
            return 0;
        }
        catch (Exception ex) { Console.Error.WriteLine(ex); return 2; }
    }
}
