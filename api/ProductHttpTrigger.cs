using System.Collections.Generic;
using System.Linq;
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

namespace Api
{
    public class ProductHttpTrigger
    {
        private readonly ILogger<ProductHttpTrigger> _logger;

        public ProductHttpTrigger(ILogger<ProductHttpTrigger> log)
        {
            _logger = log;
        }

        [FunctionName(nameof(ProductHttpTrigger.GetProductsByCategory))]
        [OpenApiOperation(operationId: "GetProductsByCategory", tags: new[] { "product" })]
        [OpenApiParameter(name: "category", In = ParameterLocation.Path, Required = true, Type = typeof(string), Description = "The **Category** parameter")]
        [OpenApiResponseWithBody(statusCode: HttpStatusCode.OK, contentType: ContentTypes.ApplicationJson, bodyType: typeof(Response), Description = "The OK response")]
        public async Task<IActionResult> GetProductsByCategory(
            [HttpTrigger(AuthorizationLevel.Anonymous, HttpVerbs.GET, Route = "products/{category}")] HttpRequest req,
            [CosmosDB(databaseName: "AdventureWorks", containerName: "products", Connection = "ConnectionStrings_CosmosDB",
                      SqlQuery = "SELECT * FROM c WHERE c.category = {category}")] IEnumerable<Product> products)
        {
            _logger.LogInformation("C# HTTP trigger function processed a request.");

            var responseMessage = default(string);
            if (!products.Any())
            {
                responseMessage = "No product found";
            }
            else
            {
                responseMessage = $"{products.Count()} product(s) found";
            }

            var response = new Response() { Message = responseMessage };
            return new OkObjectResult(response);
        }
    }
}