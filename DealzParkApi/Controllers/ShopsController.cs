using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using DealzParkApi.Data;
using DealzParkApi.Models;
using DealzParkApi.DTOs;
using Swashbuckle.AspNetCore.Annotations; // For Swagger annotations

namespace DealzParkApi.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class ShopsController : ControllerBase
    {
        private readonly ApplicationDbContext _context;

        public ShopsController(ApplicationDbContext context)
        {
            _context = context;
        }

        [HttpPost("register")]
        [SwaggerOperation(Summary = "Registers a new shop")]
        [ProducesResponseType(typeof(Shop), StatusCodes.Status201Created)]
        [ProducesResponseType(StatusCodes.Status400BadRequest)]
        public async Task<ActionResult<Shop>> RegisterShop(ShopRegistrationDto shopDto)
        {
            if (!ModelState.IsValid)
            {
                return BadRequest(ModelState);
            }

            var shop = new Shop
            {
                ShopName = shopDto.ShopName,
                NID = shopDto.NID,
                TradeLicense = shopDto.TradeLicense,
                ProductDetails = shopDto.ProductDetails,
                Location = shopDto.Location,
                Address = shopDto.Address,
                ShopType = shopDto.ShopType
            };

            _context.Shops.Add(shop);
            await _context.SaveChangesAsync();

            return CreatedAtAction(nameof(GetShop), new { id = shop.Id }, shop);
        }

        [HttpGet("{id}")]
        [SwaggerOperation(Summary = "Gets a specific shop by ID")]
        [ProducesResponseType(typeof(Shop), StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        public async Task<ActionResult<Shop>> GetShop(int id)
        {
            var shop = await _context.Shops.FindAsync(id);

            if (shop == null)
            {
                return NotFound();
            }

            return shop;
        }

        [HttpGet]
        [SwaggerOperation(Summary = "Gets all registered shops")]
        [ProducesResponseType(typeof(IEnumerable<Shop>), StatusCodes.Status200OK)]
        public async Task<ActionResult<IEnumerable<Shop>>> GetAllShops()
        {
            return await _context.Shops.ToListAsync();
        }
    }
}