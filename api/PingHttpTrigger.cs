using System.IO;
using System.Net;
using System.Threading.Tasks;

using Aliencube.AzureFunctions.Extensions.Common;

using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Azure.WebJobs;
using Microsoft.Azure.WebJobs.Extensions.Http;
using Microsoft.Azure.WebJobs.Extensions.OpenApi.Core.Attributes;
using Microsoft.Extensions.Logging;
using Microsoft.OpenApi.Models;

using Newtonsoft.Json;

namespace Api
{
    public class PingHttpTrigger
    {
        private readonly ILogger<PingHttpTrigger> _logger;

        public PingHttpTrigger(ILogger<PingHttpTrigger> log)
        {
            _logger = log;
        }

        [FunctionName(nameof(PingHttpTrigger.Ping))]
        [OpenApiOperation(operationId: "Ping", tags: new[] { "ping" })]
        [OpenApiParameter(name: "name", In = ParameterLocation.Query, Required = true, Type = typeof(string), Description = "The **Name** parameter")]
        [OpenApiResponseWithBody(statusCode: HttpStatusCode.OK, contentType: ContentTypes.ApplicationJson, bodyType: typeof(Response), Description = "The OK response")]
        public async Task<IActionResult> Ping(
            [HttpTrigger(AuthorizationLevel.Anonymous, HttpVerbs.GET, Route = "ping")] HttpRequest req)
        {
            _logger.LogInformation("C# HTTP trigger function processed a request.");

            string name = req.Query["name"];

            string requestBody = await new StreamReader(req.Body).ReadToEndAsync();
            dynamic data = JsonConvert.DeserializeObject(requestBody);
            name = name ?? data?.name;

            string responseMessage = string.IsNullOrEmpty(name)
                ? "This HTTP triggered function executed successfully. Pass a name in the query string or in the request body for a personalized response."
                : $"Hello, {name}. This HTTP triggered function executed successfully.";

            var response = new Response() { Message = responseMessage };
            return new OkObjectResult(response);
        }
    }
}