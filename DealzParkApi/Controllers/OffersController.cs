using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using DealzParkApi.Data;
using DealzParkApi.Models;
using DealzParkApi.DTOs;
using Swashbuckle.AspNetCore.Annotations;
// Remove if you're not using authentication yet
// using Microsoft.AspNetCore.Authorization;
// using System.Security.Claims;

namespace DealzParkApi.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class OffersController : ControllerBase
    {
        private readonly ApplicationDbContext _context;

        public OffersController(ApplicationDbContext context)
        {
            _context = context;
        }

        [HttpPost]
        // [Authorize] // Uncomment if you add authentication back
        [SwaggerOperation(Summary = "Creates a new offer")] // Add (Authentication Required) if authorized
        [ProducesResponseType(typeof(OfferResponseDto), StatusCodes.Status201Created)]
        [ProducesResponseType(StatusCodes.Status400BadRequest)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        // [ProducesResponseType(StatusCodes.Status401Unauthorized)] // Uncomment if authorized
        public async Task<ActionResult<OfferResponseDto>> CreateOffer(OfferCreationDto offerDto)
        {
            if (!ModelState.IsValid)
            {
                return BadRequest(ModelState);
            }

            // --- VALIDATE CATEGORY (ensure it exists in your Categories table) ---
            var categoryEntity = await _context.Categories
                                        .FirstOrDefaultAsync(c => c.Name.ToLower() == offerDto.Category.ToLower());
            if (categoryEntity == null)
            {
                return BadRequest($"Category '{offerDto.Category}' does not exist. Please create it first or choose an existing one.");
            }
            // --- END VALIDATE CATEGORY ---

            // If using authentication and want to link user:
            // var userId = User.FindFirstValue(ClaimTypes.NameIdentifier);
            // if (userId == null)
            // {
            //     return Unauthorized("User identifier not found in token. Please login again.");
            // }

            var shop = await _context.Shops.FindAsync(offerDto.ShopId);
            if (shop == null)
            {
                return NotFound($"Shop with ID {offerDto.ShopId} not found.");
            }

            // Optional: Shop ownership check if using authentication
            // if (shop.OwnerUserId != userId) // Assuming Shop has OwnerUserId
            // {
            //     return Forbid("You do not have permission to add offers to this shop.");
            // }

            var offer = new Offer
            {
                PromotionalTitle = offerDto.PromotionalTitle,
                PromotionalImageUrl = offerDto.PromotionalImageUrl,
                DiscountPercentage = offerDto.DiscountPercentage,
                ProductImageUrl = offerDto.ProductImageUrl,
                ValidFrom = offerDto.ValidFrom.ToUniversalTime(),
                ValidTo = offerDto.ValidTo.ToUniversalTime(),
                Category = categoryEntity.Name, // Use the validated category name (ensures consistent casing from DB)
                ShopId = offerDto.ShopId,
                CreatedAt = DateTime.UtcNow
                // CreatorUserId = userId, // If using authentication
            };

            _context.Offers.Add(offer);
            await _context.SaveChangesAsync();

            var responseDto = new OfferResponseDto
            {
                Id = offer.Id,
                PromotionalTitle = offer.PromotionalTitle,
                PromotionalImageUrl = offer.PromotionalImageUrl,
                DiscountPercentage = offer.DiscountPercentage,
                ProductImageUrl = offer.ProductImageUrl,
                ValidFrom = offer.ValidFrom,
                ValidTo = offer.ValidTo,
                CreatedAt = offer.CreatedAt,
                Category = offer.Category, // offer.Category is already a string
                ShopId = offer.ShopId,
                ShopName = shop.ShopName
            };

            return CreatedAtAction(nameof(GetOffer), new { id = offer.Id }, responseDto);
        }

        [HttpGet("{id}")]
        [SwaggerOperation(Summary = "Gets a specific offer by ID")]
        [ProducesResponseType(typeof(OfferResponseDto), StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        public async Task<ActionResult<OfferResponseDto>> GetOffer(int id)
        {
            var offer = await _context.Offers
                                      .Include(o => o.Shop)
                                      .FirstOrDefaultAsync(o => o.Id == id);

            if (offer == null || offer.Shop == null)
            {
                return NotFound();
            }

            var responseDto = new OfferResponseDto
            {
                Id = offer.Id,
                PromotionalTitle = offer.PromotionalTitle,
                PromotionalImageUrl = offer.PromotionalImageUrl,
                DiscountPercentage = offer.DiscountPercentage,
                ProductImageUrl = offer.ProductImageUrl,
                ValidFrom = offer.ValidFrom,
                ValidTo = offer.ValidTo,
                CreatedAt = offer.CreatedAt,
                Category = offer.Category, // offer.Category is already a string
                ShopId = offer.ShopId,
                ShopName = offer.Shop.ShopName
            };

            return responseDto;
        }

        [HttpGet]
        [SwaggerOperation(Summary = "Gets all offers, sorted by latest and highest discount")]
        [ProducesResponseType(typeof(IEnumerable<OfferResponseDto>), StatusCodes.Status200OK)]
        public async Task<ActionResult<IEnumerable<OfferResponseDto>>> GetAllOffers(
            [FromQuery] string? category = null) // category parameter is a string
        {
            var query = _context.Offers.Include(o => o.Shop).AsQueryable();

            // Filter by category if provided
            if (!string.IsNullOrEmpty(category) && category.Trim().ToLower() != "all") // Check for "all" explicitly
            {
                // Case-insensitive comparison for the category name string
                string lowerCategory = category.Trim().ToLower();
                query = query.Where(o => o.Category.ToLower() == lowerCategory);
            }

            // Date validation removed to show all offers as per your previous request
            // var currentDate = DateTime.UtcNow;
            // query = query.Where(o => o.ValidTo >= currentDate);

            var offers = await query
                .OrderByDescending(o => o.CreatedAt)       // Latest first
                .ThenByDescending(o => o.DiscountPercentage) // Then highest discount
                .Select(offer => new OfferResponseDto
                {
                    Id = offer.Id,
                    PromotionalTitle = offer.PromotionalTitle,
                    PromotionalImageUrl = offer.PromotionalImageUrl,
                    DiscountPercentage = offer.DiscountPercentage,
                    ProductImageUrl = offer.ProductImageUrl,
                    ValidFrom = offer.ValidFrom,
                    ValidTo = offer.ValidTo,
                    CreatedAt = offer.CreatedAt,
                    Category = offer.Category, // offer.Category is already a string
                    ShopId = offer.ShopId,
                    ShopName = offer.Shop != null ? offer.Shop.ShopName : "N/A"
                })
                .ToListAsync();

            return offers;
        }
    }
}