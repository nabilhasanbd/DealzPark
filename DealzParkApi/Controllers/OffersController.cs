using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using DealzParkApi.Data;
using DealzParkApi.Models;
using DealzParkApi.DTOs;
using Swashbuckle.AspNetCore.Annotations;

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

        // ... (CreateOffer and GetOffer methods remain the same) ...

        [HttpPost]
        [SwaggerOperation(Summary = "Creates a new offer")]
        [ProducesResponseType(typeof(OfferResponseDto), StatusCodes.Status201Created)]
        [ProducesResponseType(StatusCodes.Status400BadRequest)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        public async Task<ActionResult<OfferResponseDto>> CreateOffer(OfferCreationDto offerDto)
        {
            if (!ModelState.IsValid)
            {
                return BadRequest(ModelState);
            }

            var shop = await _context.Shops.FindAsync(offerDto.ShopId);
            if (shop == null)
            {
                return NotFound($"Shop with ID {offerDto.ShopId} not found.");
            }

            var offer = new Offer
            {
                PromotionalTitle = offerDto.PromotionalTitle,
                PromotionalImageUrl = offerDto.PromotionalImageUrl,
                DiscountPercentage = offerDto.DiscountPercentage,
                ProductImageUrl = offerDto.ProductImageUrl,
                ValidFrom = offerDto.ValidFrom.ToUniversalTime(), // Store in UTC
                ValidTo = offerDto.ValidTo.ToUniversalTime(),     // Store in UTC
                Category = offerDto.Category,
                ShopId = offerDto.ShopId,
                CreatedAt = DateTime.UtcNow
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
                Category = offer.Category.ToString(),
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
                                      .Include(o => o.Shop) // Include shop details
                                      .FirstOrDefaultAsync(o => o.Id == id);

            if (offer == null || offer.Shop == null) // Ensure shop is also not null if it's crucial for the DTO
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
                Category = offer.Category.ToString(),
                ShopId = offer.ShopId,
                ShopName = offer.Shop.ShopName // Safe now due to the check above
            };

            return responseDto;
        }


        [HttpGet]
        [SwaggerOperation(Summary = "Gets all offers, sorted by latest and highest discount")]
        [ProducesResponseType(typeof(IEnumerable<OfferResponseDto>), StatusCodes.Status200OK)]
        public async Task<ActionResult<IEnumerable<OfferResponseDto>>> GetAllOffers(
            [FromQuery] string? category = null)
        {
            var query = _context.Offers.Include(o => o.Shop).AsQueryable();

            // Filter by category if provided
            if (!string.IsNullOrEmpty(category) && Enum.TryParse<OfferCategory>(category, true, out var offerCategory))
            {
                query = query.Where(o => o.Category == offerCategory);
            }

            // Filter out expired offers - THIS LINE IS REMOVED/COMMENTED OUT
            // var currentDate = DateTime.UtcNow;
            // query = query.Where(o => o.ValidTo >= currentDate);


            var offers = await query
                .OrderByDescending(o => o.CreatedAt)       // Latest first
                .ThenByDescending(o => o.DiscountPercentage) // Then highest discount
                .Select(offer => new OfferResponseDto // Project to DTO
                {
                    Id = offer.Id,
                    PromotionalTitle = offer.PromotionalTitle,
                    PromotionalImageUrl = offer.PromotionalImageUrl,
                    DiscountPercentage = offer.DiscountPercentage,
                    ProductImageUrl = offer.ProductImageUrl,
                    ValidFrom = offer.ValidFrom,
                    ValidTo = offer.ValidTo,
                    CreatedAt = offer.CreatedAt,
                    Category = offer.Category.ToString(),
                    ShopId = offer.ShopId,
                    ShopName = offer.Shop != null ? offer.Shop.ShopName : "N/A"
                })
                .ToListAsync();

            return offers;
        }
    }
}