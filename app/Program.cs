using DevKimchi.App.Proxies;

using Microsoft.AspNetCore.Components.Web;
using Microsoft.AspNetCore.Components.WebAssembly.Hosting;

var builder = WebAssemblyHostBuilder.CreateDefault(args);
builder.RootComponents.Add<DevKimchi.App.App>("#app");
builder.RootComponents.Add<HeadOutlet>("head::after");

builder.Services.AddScoped(sp => new HttpClient { BaseAddress = new Uri(builder.HostEnvironment.BaseAddress) });
builder.Services.AddScoped(sp =>
{
    var client = new ProxyClient(sp.GetService<HttpClient>());
    if (!builder.HostEnvironment.IsDevelopment())
    {
        client.BaseUrl = $"{builder.HostEnvironment.BaseAddress.TrimEnd('/')}/api";
    }

    return client;
});

await builder.Build().RunAsync();